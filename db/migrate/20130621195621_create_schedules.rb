class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.time :start_time
      t.time :end_time
      t.date :start_date
      t.date :end_date
      t.boolean :sunday
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday
      t.boolean :permanent
      t.boolean :absent
      t.text :description
      t.integer :student_id

      t.timestamps
    end
  end
end
