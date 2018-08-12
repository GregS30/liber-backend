class JobTaskSerializer < ActiveModel::Serializer
  attributes :id, :segment, :start_datetime, :end_datetime, :duration, :was_held
  belongs_to :user
  belongs_to :computer
  belongs_to :scanner
  belongs_to :task_state
  belongs_to :job
  belongs_to :task
end
