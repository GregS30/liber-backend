class Api::V1::FiltersController < ApplicationController

  def index
    @clients = Client.all.order(:name)
    @projects = Project.all.order(:name)
    @workflows = Workflow.all.order(:name)

    # this is a kludge - have to move to jobs_controller and refresh whenever TaskContainer Date filter changes
    todays_date = Date.today.strftime("%Y-%m-%d")
    @jobs = Job.find_by_sql(
      <<-SQL
      select distinct j.id, j.name, j.job_num
      from jobs as j
      join job_tasks as jt on j.id = jt.job_id
      where cast(start_datetime as date) = '#{todays_date}'
      order by j.name
      SQL
    )

    @task_states = TaskState.all.order(:name)

    @task_names = TaskName.find_by_sql(
      <<-SQL
      select tn.id, tn.name
      from tasks as t
      join task_names as tn on t.task_name_id = tn.id
      join workflows as w on w.id = t.workflow_id
      where w.name = '_prototype'
      order by t.next_link
      SQL
    )

    # when would Date be meaningful in a filter? too many!
    # @result = ActiveRecord::Base.connection.exec_query(
    #   <<-SQL
    #   select distinct cast(start_datetime as date)
    #   from job_tasks
    #   order by cast(start_datetime as date)
    #   SQL
    # )
    # @task_dates = []
    # @result.each do |row|
    #   @task_dates.push(row["start_datetime"])
    # end

    @users = User.all.order(:username)
    @users_simple = []
    @users.each do |row|
      @users_simple.push({id: row["id"], username: row["username"] })
    end

    render json: {periods: get_periods(), users: @users_simple, clients: @clients, projects: @projects, workflows: @workflows, task_names: @task_names, task_states: @task_states,
      # task_dates: @task_dates,
      jobs: @jobs}

  end

  private

  def get_periods
    periods = []

    period = {name: 'today',
      start_date: Date.today.strftime('%Y-%m-%d'),
      end_date: Date.today.strftime('%Y-%m-%d')
    }
    periods << period

    yesterday = Date.today-1
    if yesterday.cwday > 5 then yesterday = Date.today-3 end

    period = {name: 'yesterday',
      start_date: yesterday.strftime('%Y-%m-%d'),
      end_date: yesterday.strftime('%Y-%m-%d')
    }
    periods << period

    periods << build_period('this week', Date.today.all_week)
    periods << build_period('this month', Date.today.all_month)
    periods << build_period('this quarter', Date.today.all_quarter)
    periods << build_period('this year', Date.today.all_year)
    periods << build_period('last week', (Date.today-7).all_week)
    periods << build_period('last month', Date.today.prev_month.all_month)
    periods << build_period('last quarter', Date.today.last_quarter.all_month)
    periods << build_period('last year', Date.today.prev_year.all_year)

  end

  def build_period(name, range)
   {name: name,
      start_date: range.first.strftime('%Y-%m-%d'),
      end_date: range.last.strftime('%Y-%m-%d')}

  end

end
