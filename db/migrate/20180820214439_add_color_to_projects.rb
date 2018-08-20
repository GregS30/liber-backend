class AddColorToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :color, :string, default: 'e3eaa7'
  end
end
