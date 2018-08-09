class CreateSkills < ActiveRecord::Migration[5.2]
  def change
    create_table :skills do |t|
      t.integer :task_id
      t.integer :user_id

      t.timestamps
    end
  end
end
