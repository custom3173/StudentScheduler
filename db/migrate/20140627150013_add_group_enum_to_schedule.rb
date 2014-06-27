class AddGroupEnumToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :group, :integer, default: 0

    reversible do |r|
      r.up do
        # migrate data to state machine
        Schedule.reset_column_information
        Schedule.all.each do |s|
          if s.read_attribute :permanent
            s.group = 'regular'
          elsif s.read_attribute :absent
            s.group = 'absent'
          else
            s.group = 'temporary'
          end
        end
      end
      r.down do
        raise ActiveRecord::IrreversibleMigration
      end
    end

    remove_column :schedules, :permanent
    remove_column :schedules, :absent
  end
end
