class AddColorToScanners < ActiveRecord::Migration[5.2]
  def change
    add_column :scanners, :color, :string, default: 'e3eaa7'
  end
end
