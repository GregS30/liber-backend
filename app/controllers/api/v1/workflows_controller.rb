class Api::V1::WorkflowsController < ApplicationController

  def index

  @result = ActiveRecord::Base.connection.exec_query(
    <<-SQL
    select distinct cast(start_datetime as date)
    from job_tasks
    order by cast(start_datetime as date)
    SQL
  )
  @task_dates = []
  @result.each do |row|
    @task_dates.push(row["start_datetime"])
  end

  end

end
