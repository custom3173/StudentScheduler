class AddAttributesToStudents < ActiveRecord::Migration
  def change
    add_column :students, :campus_id, :string
    add_column :students, :email, :string
    add_column :students, :department, :string
    add_column :students, :lims, :string
    add_column :students, :admin, :boolean
  end
end
