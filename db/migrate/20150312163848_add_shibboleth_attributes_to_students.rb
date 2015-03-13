class AddShibbolethAttributesToStudents < ActiveRecord::Migration
  def change
    add_column :students, :group, :string
    add_column :students, :displayName, :string

    rename_column :students, :username, :umbcusername
    rename_column :students, :email, :mail
    rename_column :students, :department, :umbcDepartment

    reversible do |r|
      r.up do
        Student.reset_column_information
        Student.all.each do |s|
          # change admin boolean to group string
          s.group = s.read_attribute(:admin) ? 'admin' : 'student'
          # combine displayname from individual name columns
          s.displayName = "#{s.first_name} #{s.last_name}"
          s.save validate: false
        end
      end

      r.down do
        Student.reset_column_information
        Student.all.each do |s|
          s.admin = s.group == 'admin'
          name = s.displayName.split
          s.first_name = name.first
          s.last_name = name.last
          s.save validate: false
        end
      end
    end

    remove_column :students, :first_name, :string
    remove_column :students, :last_name, :string
    remove_column :students, :campus_id, :string
    remove_column :students, :lims, :string
    remove_column :students, :admin, :boolean
  end
end
