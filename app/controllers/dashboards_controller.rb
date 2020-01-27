class DashboardsController < ApplicationController
  include DashboardsHelper
  before_action :list_of_month_and_week, only: :index

  def dbfleet_rds_availbility
    @system_groups = iterate_regions_roles_system_groups(system_groups_and_regions, 'system_group')
    @regions = iterate_regions_roles_system_groups(system_groups_and_regions, 'region')
    if params[:start_date].present?
      @start_date = params[:start_date].to_date
      @end_date = @start_date
    elsif params[:week].present?
      @start_date, @end_date, @all_dates = week_dates(@current_year, params[:week].to_i, false)
    elsif params[:month].present?
      @start_date = "#{params['year']}-#{params[:month]}-01".to_date
      @end_date = @start_date.end_of_month
    end
    @region_query = []
    if params[:system_group].kind_of?(Array)
      @start_date, @end_date, @all_dates = week_dates(@current_year, params[:week].to_i, true)
      @selected_system_groups = [{system_group: 'AFT-ITS', region: 'NA'}, {system_group: 'AFT-ITS', region: 'EU'}, {system_group: 'AFT-ITS', region: 'JP'},
                                 {system_group: 'EFP-POSTGRES', region: 'NA'}, {system_group: 'EFP-POSTGRES', region: 'EU'}, {system_group: 'EFP-POSTGRES', region: 'JP'},
                                 {system_group: 'AFT-INBOUND', region: 'NA'}, {system_group: 'AFT-INBOUND', region: 'EU'}, {system_group: 'AFT-INBOUND', region: 'JP'},
                                 {system_group: 'AFT-VENDORFLEX', region: 'NA'}, {system_group: 'AFT-VENDORFLEX', region: 'EU'}, {system_group: 'AFT-VENDORFLEX', region: 'JP'},
                                 {system_group: 'AFT-FCLM', region: 'NA'}, {system_group: 'AFT-FCLM', region: 'EU'}, {system_group: 'AFT-FCLM', region: 'JP'}, 
        ]  
      @selected_system_groups.each do |group|
        result = [] # common_filter_query(group[:system_group], 'WRITER', group[:region], @start_date, @end_date)
        group[:result] = result
        @region_query << group
      end
      results = "SELECT * FROM fleet.rptv_availability WHERE (system_group in ('AFT-ITS', 'EFP-POSTGRES', 'AFT-INBOUND', 'AFT-VENDORFLEX', 'AFT-FCLM') AND role = '#{@role_under_system_group[0]}' AND metric_date >= '#{@start_date}' AND metric_date <= '#{@end_date}')"
      
      @results = ActiveRecord::Base.connection.execute(results)
    elsif (params[:report_type].present? && params[:start_date].present? && params[:system_group].present?) || (params[:report_type].present? && params[:week].present? && params[:system_group].present?) || (params[:report_type].present? && params[:month].present? && params[:system_group].present?)
      @results = common_filter_query(params[:system_group], params[:role], params[:region], @start_date, @end_date)
      @selected_system_groups = []
      @selected_system_groups.push(params[:system_group])
      @role_under_system_group = iterate_regions_roles_system_groups(@results, 'role')
    end
    if @results.present?
      @region_under_system_group = iterate_regions_roles_system_groups(@results, 'region')
    end
  end

  def weekly_dates
    @current_year = params[:year].to_i
    @total_weeks =  (Date.today.year == params[:year].to_i) ? (Date.today.cweek - 1) : 52
    @total_weeks = (1..@total_weeks).to_a
    render json: { html: render_to_string(partial: 'weekly_dates') }
  end

  private

  def list_of_month_and_week
    # pdt datetime format
    current_date = Time.now.in_time_zone('Pacific Time (US & Canada)')
    @current_year = (params[:year].present?) ? params[:year].to_i : current_date.year
    if (Date.today.year == params[:year].to_i || params[:year].nil?)
      @total_weeks = Date.today.cweek - 1
    elsif params[:year].present?
      @total_weeks = 52
    end
    if params[:week].nil? && params[:report_type].nil? && params[:system_group].nil?
      default_dashboard_report
    end
    @total_weeks = (1..@total_weeks).to_a
    @months = Date::MONTHNAMES.compact
    # @months = @months.each_with_index.map { |month, index| month if index < current_date.month }.compact
  end

  def iterate_regions_roles_system_groups(params, key)
    params.map { |object| object[key] }.uniq
  end

  def default_dashboard_report
    params.merge!(default: true)
    params.merge!(week: @total_weeks)
    groups = ['AFT-ITS']
    params.merge!(system_group: groups)
    @role_under_system_group = ['WRITER']
  end
end
