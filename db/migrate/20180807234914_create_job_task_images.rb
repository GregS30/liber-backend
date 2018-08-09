class CreateJobTaskImages < ActiveRecord::Migration[5.2]
  def change
    create_table :job_task_images do |t|
      t.integer :job_task_id
      t.integer :image_id

      t.timestamps
    end
  end
end
