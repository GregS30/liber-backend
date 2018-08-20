class AddColorToTaskStates < ActiveRecord::Migration[5.2]
  def change
    add_column :task_states, :color, :string, default: 'e3eaa7'
  end
end
