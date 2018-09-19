class Api::V1::AnalyticsController < ApplicationController

  def index

    # Query for chart content and totals
    # and render json "rows" and "totals".

    # URL includes chart type, period start/end,
    # and optional project, task, and user filters.
    # For example:
    # 'http://localhost:3000/api/v1/analytics?chart=scanner&start=2017-01-01&finish=2017-12-31&project=3&task=&user='

    case params['chart']
      when 'scanner'
        column = 's.name'
        aggregator = 's.name'
      when 'task'
        column = 'tn.name'
        aggregator = 'tn.name'
      when 'user'
        column = 'u.username as name'
        aggregator = 'u.username'
      when 'client'
        column = 'c.name'
        aggregator = 'c.name'
      when 'project'
      column = 'p.name'
      aggregator = 'p.name'

    end

    select_part = 'select ' + column + ', count(distinct jt.job_id) as jobs, sum(jt.img_count) as images'

    from_join_part = <<-SQL
      from job_tasks as jt
      join scanners as s on s.id = jt.scanner_id
      join users as u on u.id = jt.user_id
      join tasks as t on t.id = jt.task_id
      join task_names as tn on tn.id = t.task_name_id
      join workflows as w on w.id = t.workflow_id
      join projects as p on p.id = w.project_id
      join clients c on c.id = p.client_id
    SQL

    where_part = <<-SQL
      where cast(jt.start_datetime as date) >= '#{params["start"]}'
      and cast(jt.start_datetime as date) <= '#{params["finish"]}'
    SQL

    if params['project'] != ''
      where_part = where_part + " and p.id=#{params['project']}"
    end

    if params['task'] != ''
      where_part = where_part + " and tn.id=#{params['task']}"
    end

    if params['user'] != ''
      where_part = where_part + " and u.id=#{params['user']}"
    end

    # Kludge to exclude 'Blue' (sysadmin) from 'user' chart -
    # his volume is so high, it needlessly skews the scale of the chart
    if params['chart'] == 'user'
      where_part = where_part + " and u.username <> 'Blue'"
    end

    order_group_part = <<-SQL
      group by #{aggregator}
      order by #{aggregator}
    SQL

    sql = select_part + ' ' + from_join_part + ' ' + where_part + ' ' + order_group_part

    query_result = ActiveRecord::Base.connection.exec_query(sql)

    select_part_totals = 'select count(distinct jt.job_id) as jobs, sum(jt.img_count) as images, count(distinct jt.user_id) as users, count(distinct jt.scanner_id) as scanners, count(distinct w.project_id) as projects, count(distinct jt.id) as tasks'

    sql = select_part_totals + ' ' + from_join_part + ' ' + where_part
    query_result_totals = ActiveRecord::Base.connection.exec_query(sql)

    render json: {rows: query_result, totals: query_result_totals}

  end

end
