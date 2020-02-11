class DashboardsController < ApplicationController
  include DashboardsHelper
  before_action :list_of_month_and_week, only: :dbfleet_rds_availbility

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
    @results = []
    if params[:default]
      @start_date, @end_date, @all_dates = week_dates(@current_year, params[:week].to_i, true)
      params.merge!(system_group: 'All')
      params.merge!(region: 'All')
      @regions.push('All')
      regions = ['eu-west-1', 'us-east-1', 'ap-northeast-1']
      match_array = ['AFT-ITS', 'AFT-INBOUND', 'AFT-FCLM', 'EFP-POSTGRES', 'AFT-FCLM-TEST', 'AFT-VENDORFLEX', 'PC-ARNOLD', 'AFTLI-JOBS-LEGACY', 'CAPACITYPLATFORM-PROD', 'FCINBOUNDDOCKSERVICE', 'GMP-ACCOUNT', 'SHIPEX-INDEXING', 'SHREK-SERVICE', 'TIMESERVICE', 'TIPS']
      extra_groups = @system_groups - match_array
      match_array.push(extra_groups).flatten
      match_array.flatten.uniq.each do |group|
        regions.each do |region|
          result = common_filter_query(group, 'WRITER', region, @start_date, @end_date)
          h = {system_group: "#{group}", region: "#{region}", result: result}
          @region_query.push(h)
        end
      end
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
    if (Date.today.year == params[:year].to_i) || (params[:year].nil?)
      @total_weeks = Date.today.cweek - 1
    elsif params[:year].present?
      @total_weeks = 52
    end
    if params[:week].nil? && params[:report_type].nil? && params[:system_group].nil?
      default_dashboard_report
    end
    @total_weeks = params[:start_date].present? ? [] : (1..@total_weeks).to_a
    @months = Date::MONTHNAMES.compact
    # @months = @months.each_with_index.map { |month, index| month if index < current_date.month }.compact
  end

  def iterate_regions_roles_system_groups(params, key)
    params.map { |object| object[key] }.uniq
  end

  def default_dashboard_report
    params.merge!(default: true)
    params.merge!(week: @total_weeks)
    params.merge!(role: 'WRITER')
  end
end
