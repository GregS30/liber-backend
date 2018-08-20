class AddColorToTaskNames < ActiveRecord::Migration[5.2]
  def change
    add_column :task_names, :color, :string, default: 'e3eaa7'
  end
end
