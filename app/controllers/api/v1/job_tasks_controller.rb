class Api::V1::JobTasksController < ApplicationController

  def index

    sql = "select *
          from job_tasks
          where cast(start_datetime as date) = '#{params["start_date"]}'"

    @job_tasks = JobTask.find_by_sql(sql)

    render json: @job_tasks, include: '**'

  end

end
