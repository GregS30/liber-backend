class JobTaskImage < ApplicationRecord
  belongs_to :image
  belongs_to :job_task
end
