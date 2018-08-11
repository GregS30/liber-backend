require_relative 'seeds_data'

puts('TaskState')
TaskState.destroy_all
TASK_STATE.each {|item| TaskState.create(item)}

puts('Scanner')
Scanner.destroy_all
SCANNERS.each {|item| Scanner.create(item)}

puts('Computer')
Computer.destroy_all
COMPUTERS.each {|item| Computer.create(item)}

puts('User')
User.destroy_all
USERS.each { |item|
  User.create(username: item[:username], email: item[:email].downcase!, password: "123")
}
greg = User.find_by(username: "greg")
greg.is_admin = true
greg.save

puts('Client')
Client.destroy_all
CLIENTS.each {|item| Client.create(item)}

puts('Project & Workflow')
Project.destroy_all
Workflow.destroy_all
PROJECTS.each {|item|
  project = Project.new(name: item[:name])
  project.client = Client.find_by(name: item[:client])
  project.save
  workflow = Workflow.new(name: item[:workflow])
  workflow.project = Project.find_by(name: item[:name])
  workflow.save
}

# Workflow.all.each {|item| puts("Workflow: #{item.name} / Project: #{item.project.name} / Client: #{item.project.client.name}")}

puts('Task & TaskName')
Task.destroy_all
TaskName.destroy_all
WORKFLOW_TASKS.each {|item|
  list = TaskList.new
  item[:task_name].each {|name|
    if !task_name = TaskName.find_by(name: name)
      task_name = TaskName.create(name: name)
    end

    list.append(name)
  }
  # list.print
  list.write_tasks(item[:workflow])
}

list = TaskList.new
list.read_tasks('_prototype')
# list.print

puts('JobTask')
JobTask.destroy_all
JOB_TASKS.each { |seed|
  if !j = Job.find_by(job_num: seed[:job_num])
    j = Job.new
    j.job_num = seed[:job_num]
    j.name = seed[:job_name]
    j.save
  end

  jt = JobTask.new

  task = Task.find_by_sql("select t.* from tasks t, workflows w, task_names tn where w.id = t.workflow_id and tn.id = t.task_name_id and w.name='#{seed[:workflow]}' and tn.name='#{seed[:task]}'")

  # puts("w.name='#{seed[:workflow]}' and tn.name='#{seed[:task]}'")

  jt.task_id = task[0].id

  jt.job_id = j.id
  jt.segment = "A"
  jt.user = User.find_by(username: seed[:user].downcase)

  case seed[:user]
    when "Judy"
      ws = "DELL_WS_001"
    when "Renell"
      ws = "DELL_WS_002"
    when "Candace"
      ws = "LL_WS_001"
    when "Elvie"
      ws = "LL_WS_002"
    when "ChiChi"
      ws = "LL_WS_003"
    when "Julius"
      ws = "LL_WS_004"
    when "Adrian"
      ws = "DELL_WS_003"
  end

  jt.computer = Computer.find_by(name: ws)

  jt.scanner = Scanner.find_by(name: seed[:scanner_name])
  jt.start_datetime = seed[:start_time]
  jt.end_datetime = seed[:end_time]
  jt.duration = seed[:duration]

  jt.was_held = false
  jt.task_state = TaskState.find_by(name: 'closed')

  jt.save

}
