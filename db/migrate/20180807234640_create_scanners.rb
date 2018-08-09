class CreateScanners < ActiveRecord::Migration[5.2]
  def change
    create_table :scanners do |t|
      t.string :name
      t.string :mfg
      t.string :model
      t.string :media
                
      t.timestamps
    end
  end
end
