
scanners = [
  {name: 'Cleopatra', mfg: 'Treventus', model: 'ScanRobot', media: 'Book'},
  {name: 'Wilhelmina', mfg: 'Treventus', model: 'ScanRobot', media: 'Book'},
  {name: 'Gutenberg', mfg: 'Treventus', model: 'ScanRobot', media: 'Book'},
  {name: 'Bismarck', mfg: 'Image Access', model: 'Bookeye V3R2', media: 'Book'},
  {name: 'Beethoven', mfg: 'Image Access', model: 'Bookeye V3R2', media: 'Book'},
  {name: 'MacArthur', mfg: 'Avision', model: 'FB6280', media: 'Book'},
  {name: 'Patton', mfg: 'Avision', model: 'FB6280', media: 'Book'},
  {name: 'Eisenhower', mfg: 'Avision', model: 'FB6280', media: 'Book'}
]

Scanner.destroy_all
scanners.each {|item| Scanner.create(item)}

computers = [
  {name: 'DELL_WS_001'},
  {name: 'DELL_WS_002'},
  {name: 'DELL_WS_003'},
  {name: 'DELL_WS_004'},
  {name: 'LL_WS_001'},
  {name: 'LL_WS_002'},
]

Computer.destroy_all
computers.each {|item| Computer.create(item)}

users = [
  {username: 'Greg', email: 'Greg@somemail.com', is_admin: true},
  {username: 'Mario', email: 'Mario@somemail.com'},
  {username: 'Judy', email: 'Judy@somemail.com'},
  {username: 'Renell', email: 'Renell@somemail.com'},
  {username: 'Candace', email: 'Candace@somemail.com'},
  {username: 'Elvie', email: 'Elvie@somemail.com'},
  {username: 'Mayei', email: 'Mayei@somemail.com'}
]

User.destroy_all
users.each {|item| User.create(item)}

clients = [
  {name: 'Amazon'},
  {name: 'Internet Archive'},
  {name: 'County Court'},
  {name: 'Central Synagogue'}
]

Client.destroy_all
clients.each {|item| Client.create(item)}

projects = [
  {name: 'Print on demand', client: 'Amazon', workflow: 'Book POD'},
  {name: 'Transcript', client: 'County Court', workflow: 'Transcript'},
  {name: 'Newsletter', client: 'Central Synagogue', workflow: 'Newsletter'},
  {name: 'Exhibtion catalogs', client: 'Internet Archive', workflow: 'Catalog'},
  {name: 'Sale catalogs (a)', client: 'Internet Archive', workflow: 'Catalog'},
  {name: 'Sale catalogs (f)', client: 'Internet Archive', workflow: 'Catalog'},
  {name: 'Art research books', client: 'Internet Archive', workflow: 'Book'}
]

Project.destroy_all
Workflow.destroy_all
projects.each {|item|
  project = Project.new(name: item[:name])
  project.client = Client.find_by(name: item[:client])
  project.save
  workflow = Workflow.new(name: item[:workflow])
  workflow.project = Project.find_by(name: item[:name])
  workflow.save
}

# Workflow.all.each {|item| puts("Workflow: #{item.name} / Project: #{item.project.name} / Client: #{item.project.client.name}")}

workflow_tasks = [
  {workflow: 'Book POD',
    task_name: ['check-in', 'scan', 'crop', 'adjust', 'transform', 'qa', 'output', 'checkout']},
  {workflow: 'Transcript',
    task_name: ['check-in', 'scan', 'index', 'crop', 'transform', 'qa', 'output', 'checkout']},
  {workflow: 'Newsletter',
    task_name: ['check-in', 'scan', 'crop', 'qa', 'output', 'checkout']},
  {workflow: 'Catalog',
    task_name: ['check-in', 'scan', 'covers', 'qa-capture', 'crop', 'index', 'qa', 'output', 'checkout']},
  {workflow: 'Book',
    task_name: ['check-in', 'scan', 'covers', 'qa-capture', 'crop', 'index', 'qa', 'output', 'checkout']}
]

Task.destroy_all
workflow_tasks.each {|item|
  list = TaskList.new
  item[:task_name].each {|name|
    list.append(name)
  }
  # list.print
  list.write_tasks(item[:workflow])
}

list = TaskList.new
list.read_tasks('Book POD')
list.print
