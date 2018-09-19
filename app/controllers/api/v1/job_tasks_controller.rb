class Api::V1::JobTasksController < ApplicationController

  def index

    sql=
      <<-SQL
      select *
      from job_tasks
      where cast(start_datetime as time) < current_time
      and cast(start_datetime as date) = '#{params["start_date"]}'
      order by start_datetime DESC
      SQL

    @job_tasks = JobTask.find_by_sql(sql)

    render json: @job_tasks, include: '**'

    puts(sql)
  end

end
