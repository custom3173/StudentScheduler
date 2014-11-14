class AddNicknameAndColorToStudents < ActiveRecord::Migration
  def change
    add_column :students, :nickname, :string
    add_column :students, :color, :string
  end
end
