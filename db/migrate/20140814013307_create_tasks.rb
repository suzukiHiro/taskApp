class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.datetime :due_date
      t.string :status
      t.integer :created_user_id
      t.integer :assigned_user_id

      t.timestamps
    end
  end
end
