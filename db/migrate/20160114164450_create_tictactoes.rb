class CreateTictactoes < ActiveRecord::Migration
  def change
    create_table :tictactoes do |t|
      t.references :user
      t.integer :pass
      t.integer :fail
      t.integer :total
      t.timestamps null: false
    end
    add_index :tictactoes, :user_id, unique: true
  end
end
