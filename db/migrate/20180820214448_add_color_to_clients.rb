class AddColorToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :color, :string, default: 'e3eaa7'
  end
end
