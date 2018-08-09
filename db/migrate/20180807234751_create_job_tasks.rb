class CreateJobTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :job_tasks do |t|
      t.integer :task_id
      t.integer :job_id
      t.string :name
      t.string :segment
      t.integer :user_id
      t.integer :computer_id
      t.integer :scanner_id
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.integer :duration, default: 0
      t.boolean :is_running, default: false
      t.boolean :is_closed, default: false
      t.boolean :was_held, default: false

      t.timestamps
    end
  end
end
