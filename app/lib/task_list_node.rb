class TaskListNode
  attr_accessor :next, :next_link
  attr_reader   :value, :link, :db_task

  def initialize(value, link, db_task)
    @value = value
    @link = link
    @next  = nil
    @next_link = nil
    @db_task = db_task
  end

  def to_s
    "Node (link) #{@link} (value) #{@value} (next_link) #{@next_link}"
  end
end
