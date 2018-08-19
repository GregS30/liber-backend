class Api::V1::AnalyticsController < ApplicationController

  def index

    sample_url =
    'http://localhost:3000/api/v1/analytics?chart=scanner&start=2017-01-01&finish=2017-12-31&project=3&task=&user='

    case params['chart']
      when 'scanner'
        aggregator = 's.name'
      when 'task'
        aggregator = 'tn.name'
      when 'user'
        aggregator = 'u.username'
    end

    select_part = 'select ' + aggregator + ', count(distinct jt.job_id) as jobs, sum(jt.img_count) as images'

    from_join_part = <<-SQL
      from job_tasks as jt
      join scanners as s on s.id = jt.scanner_id
      join users as u on u.id = jt.user_id
      join tasks as t on t.id = jt.task_id
      join task_names as tn on tn.id = t.task_name_id
      join workflows as w on w.id = t.workflow_id
      join projects as p on p.id = w.project_id
    SQL

    where_part = <<-SQL
      where cast(jt.start_datetime as date) >= '#{params["start"]}'
      and cast(jt.start_datetime as date) <= '#{params["finish"]}'
      and p.id = #{params["project"]}
    SQL

    if params['task'] != '' && params['chart'] != 'task'
      where_part = where_part + " and tn.id=#{params['task']}"
    end

    if params['user'] != '' && params['chart'] != 'user'
      where_part = where_part + " and u.id=#{params['user']}"
    end

    order_group_part = <<-SQL
      group by #{aggregator}
      order by #{aggregator}
    SQL

    sql = select_part + ' ' + from_join_part + ' ' + where_part + ' ' + order_group_part

    query_result = ActiveRecord::Base.connection.exec_query(sql)

    render json: query_result

  end

end
