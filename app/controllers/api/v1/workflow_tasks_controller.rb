class Api::V1::WorkflowTasksController < ApplicationController

  def index

    sql =
      <<-SQL
      select c.id as client_id, c.name as client_name, c.color as client_color,
      p.id as project_id, p.name as project_name, p.color as project_color,
      w.id as workflow_id, w.name as workflow_name,
      t.id as task_id, t.next_link,
      tn.id as task_name_id, tn.name as task_name, tn.color as task_color
      from tasks as t
      join task_names as tn on tn.id = t.task_name_id
      join workflows as w on w.id = t.workflow_id
      join projects as p on p.id = w.project_id
      join clients as c on c.id = p.client_id
      SQL

    where_part = "where"
    if params['client'] != ''
      where_part = where_part + " c.id=#{params['client']}"
    end

    if params['project'] != ''
      where_part == "where" ? connector = " " : connector = " and "
      where_part = where_part + connector + "p.id=#{params['project']}"
    end

    if params['workflow'] != ''
      where_part == "where" ? connector = " " : connector = " and "
      where_part = where_part + connector + "w.id=#{params['workflow']}"
    end

    order_part = " order by w.id, c.name, p.name, t.next_link"
    where_part == "where" ? sql = sql + order_part : sql = sql + where_part + order_part

    @workflows = ActiveRecord::Base.connection.exec_query(sql)

    render json: @workflows

  end

end