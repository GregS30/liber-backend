class Api::V1::FiltersController < ApplicationController

  def index
    @clients = Client.all.order(:name)
    @projects = Project.all.order(:name)
    @workflows = Workflow.all.order(:name)
    @tasks = Task.all.order(:name)
    @jobs = Job.all.order(:name)

    render json: {clients: @clients, projects: @projects, workflows: @workflows, tasks: @tasks, jobs: @jobs}
  end

end
