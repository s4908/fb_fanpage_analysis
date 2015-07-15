class CreateStatistics < ActiveRecord::Migration
  def change
    create_table :statistics do |t|
      t.string :page_id
      t.string :name
      t.text :picture

      t.timestamps null: false
    end
  end
end
