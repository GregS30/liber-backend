class Api::V1::FiltersController < ApplicationController

  def index
    @users = User.all.order(:username)
    @clients = Client.all.order(:name)
    @projects = Project.all.order(:name).as_json
    @workflows = Workflow.all.order(:name)
    @jobs = Job.all.order(:job_num)
    @task_states = TaskState.all.order(:name)

    @task_names = TaskName.find_by_sql(
      "select tn.* from tasks t, task_names tn, workflows w
      where w.id = t.workflow_id
      and t.task_name_id = tn.id
      and w.name = '_prototype'
      order by t.next_link"
    )

    @connection = ActiveRecord::Base.connection
    @result = @connection.exec_query('select distinct cast(start_datetime as date) from job_tasks order by cast(start_datetime as date)')

    @task_dates = []
    @result.each do |row|
      @task_dates.push(row["start_datetime"])
    end

    render json: {users: @users, clients: @clients, projects: @projects, workflows: @workflows, task_names: @task_names, task_states: @task_states, task_dates: @task_dates, jobs: @jobs}
  end

end
