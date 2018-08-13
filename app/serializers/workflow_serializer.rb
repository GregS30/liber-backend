class WorkflowSerializer < ActiveModel::Serializer
  attributes :id, :name
  belongs_to :project
end
