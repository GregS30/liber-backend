class TaskSerializer < ActiveModel::Serializer
  attributes :id, :workflow_id, :is_active
  belongs_to :task_name
  belongs_to :workflow
end
