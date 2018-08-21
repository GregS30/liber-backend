require_relative 'seeds_data'
require 'csv'

CSV_PATH = '/Users/gregs/Development/m5/task-data/'

$dell = 0
$lian_lee = 0
$echo_all = false
$echo_new = true

$user_computers = []

def is_valid_integer(value)
  return value.is_a? Integer
end

def get_scanner(name)

  scanner = case name
  when 'AVision' then 'Sally'
  when 'Avision' then 'Sally'
  when 'BE3' then 'Beethoven'
  when 'FJ-5950' then 'Thatcher'
  when 'Mercury' then 'Sally'
  when 'PL' then 'Sally'
  when 'Plustek' then 'Sally'
  when 'SR' then 'Gutenberg'
  else name
  end

  return scanner
end

def derive_img_count(task, images, foldouts, ref_count)

  img_count = images

  # when task is covers, set img_count to 6 (arbitrary?), and add foldouts
  if task == 'covers'
    if is_valid_integer(foldouts)
      img_count = 6 + foldouts.to_i
    else
      img_count = 6
    end
  end

  # set img_count to ref images when task is index
  if task == 'index' && is_valid_integer(ref_count)
    img_count = ref_count.to_i
  end

  return img_count
end

def derive_project_name(name)

  if name.upcase != 'UNK'
    project = Project.find_by(proj_code: name).name
  else
    slice1 = name.slice(0)
    slice2 = name.slice(0, 2).rstrip
    slice3 = name.slice(0, 3).rstrip

    if slice1 == '+' || is_valid_integer(slice3) || slice1 == 'M' || slice2 == 'MM'
      project = 'Monograph'
    elsif
      project = case slice3.upcase
      when 'AS' then 'Catalog (as)'
      when 'FS' then 'Catalog (fs)'
      when 'FSS' then 'Catalog (fs)'
      when 'EX.' then 'Catalog (ex)'
      when 'EX' then 'Catalog (ex)'
      when 'AP1' then 'Periodical'
      when 'AP2' then 'Periodical'
      else 'Periodical'
      end
    end

  end
  if $echo_all then puts("project '#{name}' => '#{project}'") end
  return project
end

def derive_task_name(project, name)

  task = case name
  when 'C-Check' then 'qa-capture'
  when 'Closed' then 'checkout'
  when 'Covers' then 'covers'
  when 'Crop' then 'crop'
  when 'Gallery' then 'export'    # kludge
  when 'Hold' then 'hold'
  when 'Index' then 'index'
  when 'Index 2' then 'index'
  when 'Inserts' then 'inserts'
  when 'Photo ID' then 'index'
  when 'Priced' then 'index'
  when 'QC' then 'qa'
  when 'Ready' then 'repack'    # kludge
  when 'Rotate' then 'crop'     # count of only 1
  when 'Scan' then 'scan'
  when 'Tiled' then 'mutate'
  when 'Logged' then 'check-in'   # this won't happen
  when 'Repacked' then 'repack'   # this won't happen
  else ''     # this should not happen
  end

  # Logged and Repacked were excluded from Scan Stats "Jobs Finalized Jobs section - check with Iwachow?????

  # index task changes to split
  if project == 'Transcript' && task == 'c-check'
    task = 'split'
  end

  # kludge, some tasks are meaningless for some projects
  if (project == 'Transcript' || project == 'Print on demand' || project == 'Newsletter' || project == 'Playbills') && (task == 'covers' || task == 'qa-capture')
    if $echo_all then puts("#{task} task skipped for #{project}") end
    task = ''
  end

  if (project == 'Transcript' || project == 'Print on demand' || project == 'Newsletter' || project == 'Playbills') && (task == 'index')
    if $echo_all then puts("#{task} task skipped for #{project}") end
    task = ''
  end


  if $echo_all then puts("task '#{name}' => '#{task}'") end

  return task

end

def insert_computer(username)
  # always invoke when inserting a new user - every user needs their own computer!
  u = username.slice(0).upcase
  if u >= 'A' and u <= 'F'
    $dell = $dell + 1
    name = 'DELL-WS-' + $dell.to_s.rjust(3, "0")
  else
    $lian_lee = $lian_lee + 1
    name = 'LL-WS-' + $lian_lee.to_s.rjust(3, "0")
  end

  if $echo_new then puts("New Computer '#{username}' => '#{name}'") end
  new_computer = Computer.create(name: name)
  return new_computer
end

def insert_scanner(import_name)
  name = get_scanner(import_name)
  if !scanner = Scanner.find_by(name: name)
    if $echo_new then puts("New Scanner '#{import_name}' => '#{name}'") end
    scanner = Scanner.create(name: name)
  end
  return scanner
end

def insert_user(username)
  if username == 'Jason' || username == 'Iwachow'
    username = 'Blue'
  end
  if user = User.find_by(username: username)
    computer = $user_computers.find {|uc| uc[:user].username == username}[:computer]
  else
    if $echo_new then puts("New User ' #{username}'") end
    user = User.create(username: username, email: username.downcase + "@bcw-usa.com", password: "123")
    computer = insert_computer(username)
    $user_computers.push({user: user, computer: computer})
  end

  return {user: user, computer: computer}
end

def assign_is_admin
  if greg = User.find_by(username: "Greg")
    greg.is_admin = true
    greg.save
  end
  if blue = User.find_by(username: "Blue")
    blue.is_admin = true
    blue.save
  end
end

def insert_job(num, name)

  if !j = Job.find_by(job_num: num)
    j = Job.create(job_num: num, name: name)
  end

  return j
end

def get_user_computers
  # every user has only 1 computer but only way to find it is through job_tasks
  users = User.all
  users.each {|user|
    computer = Computer.find_by_sql(
      <<-SQL
        select distinct c.*
        from computers as c
        join job_tasks as jt on c.id = jt.computer_id
        where jt.user_id = #{user.id}
      SQL
    )
    $user_computers.push({user: user, computer:computer[0]})
  }

  if $echo_all then
    $user_computers.each {|uc| puts("#{uc[:user].username} => #{uc[:computer].name}")}
  end

end

def import_scanstats
  files = [
    '01A', '01B', '02-03A', '02-03B', '02-03C', '04', '05-06A', '05-06B', '05-06C', '07-08A', '07-08B', '07-08C', '09-10A', '09-10B', '09-10C', '11-12A', '11-12B', '2017'
  ]

  total_count = 0
  Import.destroy_all
  files.each {|fn|
    filename = CSV_PATH + fn + ' ready.csv'

    puts(filename)
    count = 0
    CSV.foreach(filename, headers: true, header_converters: :symbol) do |row|
      @import = Import.new(row.to_hash)
      @import.save
      count = count + 1
      if count % 5000 == 0
        puts("row #{count}", row)
      end
    end
    puts("#{count} rows imported")
    total_count = total_count + count
  }
  puts("#{total_count} total rows imported")

end

def initial_setup
  puts('TaskState')
  TaskState.destroy_all
  TASK_STATE.each {|item| TaskState.create(item)}

  puts('TaskName')
  TaskName.destroy_all
  TASK_NAME.each {|item| TaskName.create(item)}

  puts('Scanner')
  Scanner.destroy_all
  SCANNERS.each {|item| Scanner.create(item)}

  puts('Computer (destroy)')
  Computer.destroy_all

  puts('User (destroy)')
  User.destroy_all

  puts('Client')
  Client.destroy_all
  CLIENTS.each {|item| Client.create(item)}

  puts('Project & Workflow')
  Project.destroy_all
  Workflow.destroy_all
  PROJECTS.each {|item|
    project = Project.new(name: item[:name], proj_code: item[:proj_code])
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
    if $echo_all then list.print end
    workflows = Workflow.where(name: item[:workflow])
    workflows.each{ |wf| list.write_tasks(wf.id) }
  }

  list = TaskList.new
  list.read_tasks('_prototype', '_prototype')
  if $echo_all then list.print end

end

def seed_test_data
  puts('JobTask')

  JOB_TASKS.each { |seed|
    if !j = Job.find_by(job_num: seed[:job_num])
      j = Job.new
      j.job_num = seed[:job_num]
      j.name = seed[:job_name]
      j.save
    end

    jt = JobTask.new

    task = Task.find_by_sql("select t.* from tasks t, workflows w, task_names tn where w.id = t.workflow_id and tn.id = t.task_name_id and w.name='#{seed[:workflow]}' and tn.name='#{seed[:task]}'")

    if $echo_all then puts("w.name='#{seed[:workflow]}' and tn.name='#{seed[:task]}'") end

    jt.task_id = task[0].id

    jt.job_id = j.id
    jt.segment = "A"
    user_and_computer = insert_user(seed[:user])
    jt.user = user_and_computer[:user]

    jt.computer = user_and_computer[:computer]
    jt.scanner = Scanner.find_by(name: seed[:scanner_name])
    jt.start_datetime = seed[:start_time]
    jt.end_datetime = seed[:end_time]
    jt.duration = seed[:duration]

    jt.was_held = false
    jt.task_state = TaskState.find_by(name: 'closed')
    jt.img_count = seed[:images]

    if !jt.save
      puts("JobTask save failed!!!!!")
      break
    end
  }
end

def seed_scanstats

  import_years = [2017] #[2012, 2013, 2014, 2015, 2016, 2017]

  grand_count = 0
  skip_count = 0

  # import 1 year at a time
  import_years.each{ |year|
    task_count = 0

    # query for import records for this year - from jan 1 to dec 31
    puts("\nquery raw import for year #{year}")
    sql = <<-SQL
      select * from imports
      where datetext >= '#{year.to_s + '-01-01'}'
      and datetext <= '#{year.to_s + '-12-31'}'
    SQL
    task_import = ActiveRecord::Base.connection.exec_query(sql)

    task_import.each{ |ti|

      task_count = task_count + 1
      if $echo_all || task_count % 1000 == 0 then puts(
        "\nYear: #{year} Count: #{task_count} Job: #{ti["job_num"]} Task:  '#{ti["state"]}' Images: '#{ti["images"]}'") end

      jt = JobTask.new
      project_name = derive_project_name(ti["proj"])
      task_name = derive_task_name(project_name, ti["state"]) # task column is mis-named

      # some tasks are meaningless depending on the project, will come back as '' from derive_task_name()
      if task_name == ''
        skip_count = skip_count + 1
        next
      end

      jt.segment = "A"
      jt.start_datetime = ti["datetext"]
      jt.end_datetime = ti["datetext"]
      jt.duration = 0

      user_and_computer = insert_user(ti["op"])
      jt.user = user_and_computer[:user]
      jt.computer = user_and_computer[:computer]
      jt.scanner = insert_scanner(ti["scanner"])
      jt.job = insert_job(ti["job_num"], ti["job_name"])
      jt.task_state = TaskState.find_by(name: 'closed')

      jt.img_count = derive_img_count(task_name, ti["images"].to_i, ti["fos"], ti["ref"])
      ti["held"].upcase == 'X' ? jt.was_held = true : jt.was_held = false

      task = Task.find_by_sql(
        <<-SQL
        select p.name, w.name, tn.id, tn.name, t.id
        from projects p
        join workflows w on p.id = w.project_id
        join tasks t on w.id = t.workflow_id
        join task_names tn on tn.id = t.task_name_id
        where p.name='#{project_name}'
        and tn.name='#{task_name}'
        SQL
      )

      jt.task_id = task[0].id

      if !jt.save
        puts("JobTask save failed!!!!!")
        break
      end

    }
    puts("\nyear #{year} completed, #{task_count} rows seeded\n")
    grand_count = grand_count + task_count
  }
  puts("\n\n#{grand_count} total rows seeded")
  puts("#{skip_count} total rows skipped\n\n")

end

def update_color
  TASK_STATE.each {|item|
    if ts = TaskState.find_by(name: item[:name])
      ts.color = item[:color]
      ts.save
    end
  }

  SCANNERS.each {|item|
    if ts = Scanner.find_by(name: item[:name])
      ts.color = item[:color]
      ts.save
    end
  }

  TASK_NAME.each {|item|
    if ts = TaskName.find_by(name: item[:name])
      ts.color = item[:color]
      ts.save
    end
  }

  CLIENTS.each {|item|
    if ts = Client.find_by(name: item[:name])
      ts.color = item[:color]
      ts.save
    end
  }

  PROJECTS.each {|item|
    if ts = Project.find_by(name: item[:name])
      ts.color = item[:color]
      ts.save
    end
  }

  USER_NAMES.each {|item|
    if ts = User.find_by(username: item[:name])
      ts.color = item[:color]
      ts.save
    end
  }


end

def process_now

  # (1)  DO NOT UNCOMMMENT import_scanstats unless db was reset!!!!
  # import_scanstats

  # (2)
  # initial_setup

  # (3)
  get_user_computers
  seed_test_data

  # (4)
  # get_user_computers
  # seed_scanstats
  # assign_is_admin

  # update_color

end

process_now
