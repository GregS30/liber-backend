class CreateJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :jobs do |t|
      t.string :name
      t.integer :job_num

      t.timestamps
    end
  end
end
