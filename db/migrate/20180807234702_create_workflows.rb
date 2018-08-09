class CreateWorkflows < ActiveRecord::Migration[5.2]
  def change
    create_table :workflows do |t|
      t.string :name
      t.integer :project_id
      t.integer :head_link, default: 1

      t.timestamps
    end
  end
end
