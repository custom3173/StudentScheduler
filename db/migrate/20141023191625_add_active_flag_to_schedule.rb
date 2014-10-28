class AddActiveFlagToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :active, :boolean, default: true
  end
end
