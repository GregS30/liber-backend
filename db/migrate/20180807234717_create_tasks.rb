class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.integer :link
      t.integer :next_link
      t.integer :workflow_id
      t.integer :task_name_id

      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end
