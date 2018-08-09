class Project < ApplicationRecord
  has_many :workflows
  belongs_to :client
end
