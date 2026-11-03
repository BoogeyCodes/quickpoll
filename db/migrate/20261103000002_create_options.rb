class CreateOptions < ActiveRecord::Migration[7.1]
  def change
    create_table :options do |t|
      t.references :poll, null: false, foreign_key: true
      t.string :label, null: false

      t.timestamps
    end
  end
end
