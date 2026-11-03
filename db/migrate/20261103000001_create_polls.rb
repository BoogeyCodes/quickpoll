class CreatePolls < ActiveRecord::Migration[7.1]
  def change
    create_table :polls do |t|
      t.string :question, null: false
      t.boolean :closed, null: false, default: false

      t.timestamps
    end
  end
end
