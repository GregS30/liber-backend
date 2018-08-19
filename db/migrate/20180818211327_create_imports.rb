class CreateImports < ActiveRecord::Migration[5.2]
  def change
    create_table :imports do |t|
      t.string :proj
      t.string :op
      t.string :state
      t.string :job_num
      t.string :job_name
      t.string :images
      t.string :fos
      t.string :ref
      t.string :held
      t.string :scanner
      t.string :datetext

      t.timestamps
    end
  end
end
