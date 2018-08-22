class Api::V1::WorkflowTasksController < ApplicationController

  def index

    sql=
      <<-SQL
      select c.id as client_id, c.name as client_name,
      p.id as project_id, p.name as project_name,
      w.id as workflow_id, w.name as workflow_name,
      t.id as task_id, t.next_link,
      tn.id as task_name_id, tn.name as task_name
      from tasks as t
      join task_names as tn on tn.id = t.task_name_id
      join workflows as w on w.id = t.workflow_id
      join projects as p on p.id = w.project_id
      join clients as c on c.id = p.client_id
      order by w.id, c.name, p.name, t.next_link
      SQL

    @workflows = ActiveRecord::Base.connection.exec_query(sql)

    render json: @workflows

  end

end
