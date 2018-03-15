class CreateGrades < ActiveRecord::Migration[5.2]
  def change
    create_table :grades do |t|
      t.integer :student_id
      t.string :grade
      t.integer :course_id
      t.string :semester
    end
  end
end
