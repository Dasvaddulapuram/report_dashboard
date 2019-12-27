module DashboardsHelper
  TOTAL_MINUTES = 1440.0

  # calculate daily percentage
  def daily_percentage(max_mins)
    calcuated_percent = (max_mins.to_f / TOTAL_MINUTES) * 100
    calcuated_percent.round(2)
  end

  # calculate week and month percentage based on sum & count of total record
  def overall_weekly_and_monthly_percentage(sum, count)
    divided_by = TOTAL_MINUTES * count
    calcuated_percent = (sum.to_f / divided_by) * 100
    calcuated_percent.nan? ? 0 : calcuated_percent.round(2)
  end

  # query to get filter record by metric_date, system_group, role, etc
  def common_filter_query(system_group, role, region, start_date, end_date)
    sql = if system_group.present? && role.present? && region.present?
            "SELECT * FROM rptv_avai_tables WHERE (system_group = '#{system_group}' AND region = '#{region}' AND role = '#{role}' AND metric_date >= '#{start_date}' AND metric_date <= '#{end_date}') order by metric_date"
          elsif (system_group.present? && region.present?) || (system_group.present? && role.present?) || (region.present? && role.present?)
            "SELECT * FROM rptv_avai_tables WHERE ((system_group = '#{system_group}' AND region = '#{region}' AND metric_date >= '#{start_date}' AND metric_date <= '#{end_date}') OR (system_group = '#{system_group}' AND role = '#{role}' AND metric_date >= '#{start_date}' AND metric_date <= '#{end_date}') OR (region = '#{region}' AND role = '#{role}' AND metric_date >= '#{start_date}' AND metric_date <= '#{end_date}')) order by metric_date"
          elsif system_group.present? || region.present? || role.present?
            "SELECT * FROM rptv_avai_tables WHERE ((system_group = '#{system_group}' AND metric_date >= '#{start_date}' AND metric_date <= '#{end_date}') OR (region ='#{region}' AND metric_date >= '#{start_date}' AND metric_date <= '#{end_date}') OR (role = '#{role}' AND metric_date >= '#{start_date}' AND metric_date <= '#{end_date}')) order by metric_date"
    end
    # This command will return a set of values as a hash and put them into the results variable
    results = ActiveRecord::Base.connection.execute(sql)
    results.present? ? results : []
  end

  # fetching week's start date and end date
  def week_dates(year, week_no)
    week_start = Date.commercial(year, week_no, 1)
    week_end = Date.commercial(year, week_no, 7)
    all_dates = (week_start..week_end).to_a
    [week_start, week_end, all_dates]
  end

  # fetch uniq system groups and regions to show in drop down
  def system_groups_and_regions
    uniq_records = 'select distinct system_group, region from
                    rptv_avai_tables;'
    ActiveRecord::Base.connection.execute(uniq_records)
  end

  # prepare start date and end date format
  def start_date_end_date_format(start_date, end_date, week_no)
    "Week#{week_no} - #{start_date.strftime('%b %d')} To #{end_date.strftime('%b
     %d')}"
  end
end
