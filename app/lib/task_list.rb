class TaskList

  attr_reader :head, :link

  def initialize
    @head = nil
    @link = 1
  end

  def append(value, db_task=nil)
    if @head
      tail = find_tail
      tail.next_link = @link
      tail.next = TaskListNode.new(value, @link, db_task)
    else
      @head = TaskListNode.new(value, @link, db_task)
    end
    @link += 1
  end

  def find_tail
    node = @head

    return node if !node.next
    return node if !node.next while (node = node.next)
  end

  def append_after(target, value)
    node           = find(target)

    return unless node

    old_next       = node.next
    node.next_link = @link
    node.next      = TaskListNode.new(value, @link)
    node.next.next = old_next
    node.next.next_link = old_next.link
    @link += 1
  end

  def find(value)
    node = @head

    return false if !node.next
    return node  if node.value == value

    while (node = node.next)
      return node if node.value == value
    end
  end

  def delete(value)
    if @head.value == value
      @head = @head.next
      return
    end

    node      = find_before(value)
    node.next = node.next.next
    node.next_link = node.next.link
  end

  def find_before(value)
    node = @head

    return false if !node.next
    return node  if node.next.value == value

    while (node = node.next)
      return node if node.next && node.next.value == value
    end
  end

  def print
    return if !node = @head
    puts node

    while (node = node.next)
      puts node
    end
  end

  def write_tasks(workflow_name)
    return if !node = @head

    new_task(node, workflow_name)

    while (node = node.next)
      new_task(node, workflow_name)
    end
  end

  def new_task(node, workflow_name)
    task = Task.new
    task.name = node.value
    task.nickname = node.value
    task.link = node.link
    task.next_link = node.next_link
    task.workflow = Workflow.find_by(name: workflow_name)
    task.save
  end

  def read_tasks(workflow_name)
    tasks = Workflow.find_by(name: workflow_name).tasks.order(:next_link)
    tasks.each{ |db_task|
      self.append(db_task.name, db_task)
    }
  end

end
