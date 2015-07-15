class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer :statistic_id
      t.string :uid
      t.string :name
      t.text :picture
      t.integer :like_count
      t.integer :comment_count
      t.text :comment

      t.timestamps null: false
    end
  end
end
