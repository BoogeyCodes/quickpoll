class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.references :poll, null: false, foreign_key: true
      t.references :option, null: false, foreign_key: true
      t.string :voter_token, null: false

      t.timestamps
    end

    # One vote per voter per poll, enforced at the database level as well as in the model.
    add_index :votes, %i[poll_id voter_token], unique: true
  end
end
