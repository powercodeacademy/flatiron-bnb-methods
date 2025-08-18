class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.text :description
      t.integer :rating
      t.integer :guest_id
      t.integer :reservation_id
      t.timestamps null: false
    end
  end
end
