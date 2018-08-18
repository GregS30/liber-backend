class Api::V1::JobTasksController < ApplicationController

  def index

    # get tasks that have started prior to the current time
    # have to use UTC time to work with find_by_sql (?)

    # NOTE!!!!! no result before around 8am in the morning
   beforeTimeNow = DateTime.current.utc.strftime("%H:%M")

    # NOTE!!!!! use this AFTER 8pm
    # beforeTimeNow = DateTime.current.strftime("%H:%M")

    sql =
      "select *
      from job_tasks
      where cast(start_datetime as time) < '#{beforeTimeNow}'
      and cast(start_datetime as date) = '#{params["start_date"]}'
      order by start_datetime DESC"

    @job_tasks = JobTask.find_by_sql(sql)

    render json: @job_tasks, include: '**'

  end

end
