class Api::V1::FiltersController < ApplicationController

  def index
    @scanners = Scanner.all.order(:name)
    @clients = Client.all.order(:name)
    @projects = Project.all.order(:name)
    @workflows = Workflow.all.order(:name)

    @jobs = []
    # this is a kludge - have to move to jobs_controller and refresh whenever TaskContainer Date filter changes
    # todays_date = Date.today.strftime("%Y-%m-%d")
    # @jobs = Job.find_by_sql(
    #   <<-SQL
    #   select distinct j.id, j.name, j.job_num
    #   from jobs as j
    #   join job_tasks as jt on j.id = jt.job_id
    #   where cast(start_datetime as date) = '#{todays_date}'
    #   order by j.name
    #   SQL
    # )

    @task_states = TaskState.all.order(:name)

    @task_names = TaskName.find_by_sql(
      <<-SQL
      select tn.id, tn.name, tn.color
      from tasks as t
      join task_names as tn on t.task_name_id = tn.id
      join workflows as w on w.id = t.workflow_id
      where w.name = '_prototype'
      order by t.next_link
      SQL
    )

    @tasks = []

    # @tasks = Task.find_by_sql(
    #   <<-SQL
    #   select id, link, next_link, workflow_id, task_name_id
    #   from tasks
    #   order by workflow_id, next_link
    #   SQL
    # )


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
      @users_simple.push({id: row["id"], name: row["username"], color: row["color"] })
    end

    render json: {tasks: @tasks, periods: get_periods(), scanners: @scanners, users: @users_simple, clients: @clients, projects: @projects, workflows: @workflows, task_names: @task_names, task_states: @task_states,
      # task_dates: @task_dates,
      jobs: @jobs
    }

  end

  private

  def get_periods
    # We don't have a real factory, but we have real data from 2012 to 2017
    # with largest volume of data from 2013 to 2015. Periods filter is used
    # with Analytics, so we want to have realistic data.  The real_factory
    # variable indicates whether or not we are operating an actual factory.
    # Since we are not, the Periods are random.
    real_factory = false
    periods = []

    # Today is also used for Tasks page, and we have special test data
    # seeded for 9/13/18, so hard-code Today to that date.
    period = {name: 'today',
      start_date: real_factory ? Date.today.strftime('%Y-%m-%d') : '2018-09-13',
      end_date: real_factory ? Date.today.strftime('%Y-%m-%d') : '2018-09-13'
    }
    periods << period

    # Base all other periods on a random date between 2013 and 2015
    # (48 to 72 months ago)
    # which are the years with the highest volume of data
    random_date_this_year = Date.today.months_ago(rand(48..72))
    random_date_last_year = Date.today.months_ago(rand(48..72))

    yesterday = real_factory ? Date.today-1 : random_date_this_year - 1

    # If yesterday falls on a Saturday or Sunday, then force it to a weekday
    if yesterday.cwday > 5 then yesterday = yesterday.prev_weekday end

    period = {name: 'yesterday',
      start_date: yesterday.strftime('%Y-%m-%d'),
      end_date: yesterday.strftime('%Y-%m-%d')
    }
    periods << period

    if real_factory
      periods << build_period('this week', Date.today.all_week)
      periods << build_period('this month', Date.today.all_month)
      periods << build_period('this quarter', Date.today.all_quarter)
      periods << build_period('this year', Date.today.all_year)
      periods << build_period('last week', (Date.today-7).all_week)
      periods << build_period('last month', Date.today.last_month.all_month)
      periods << build_period('last quarter', Date.today.last_quarter.all_quarter)
      periods << build_period('last year', Date.today.prev_year.all_year)
    else
      periods << build_period('this week', random_date_this_year.all_week)
      periods << build_period('this month', random_date_this_year.all_month)
      periods << build_period('this quarter', random_date_this_year.all_quarter)
      periods << build_period('this year', random_date_this_year.all_year)
      periods << build_period('last week', random_date_last_year.all_week)
      periods << build_period('last month', random_date_last_year.all_month)
      periods << build_period('last quarter', random_date_last_year.all_quarter)
      periods << build_period('last year', random_date_last_year.all_year)

    end

  end

  def build_period(name, range)
   {name: name,
      start_date: range.first.strftime('%Y-%m-%d'),
      end_date: range.last.strftime('%Y-%m-%d')}

  end

end
