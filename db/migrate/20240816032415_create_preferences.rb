class CreatePreferences < ActiveRecord::Migration[7.0]
  def change
    create_table :preferences do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :timer_duration
      t.integer :break_duration
      t.integer :long_break_duration

      t.timestamps
    end
  end
end
