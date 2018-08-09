class JobTask < ApplicationRecord
  has_many :job_task_images
  belongs_to :task
  belongs_to :job
  belongs_to :scanner
  belongs_to :computer
  belongs_to :user
end
