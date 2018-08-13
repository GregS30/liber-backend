class TaskSerializer < ActiveModel::Serializer
  attributes :id
  belongs_to :task_name
  belongs_to :workflow
end
