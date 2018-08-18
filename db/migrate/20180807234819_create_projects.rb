class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :client_id
      t.string :proj_code

      t.timestamps
    end
  end
end
