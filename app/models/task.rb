class Task < ApplicationRecord
  has_many :skills
  has_many :job_tasks
  belongs_to :workflow
  belongs_to :task_name
end
