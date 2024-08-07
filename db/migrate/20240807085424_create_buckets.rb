class CreateBuckets < ActiveRecord::Migration[7.0]
  def change
    create_table :buckets do |t|
      t.integer :user_id
      t.boolean :filled
      t.integer :starttime
      t.integer :endtime
      t.integer :duration
      t.integer :storage
      t.text :notes
      t.datetime :completed_at

      t.timestamps
    end
  end
end
