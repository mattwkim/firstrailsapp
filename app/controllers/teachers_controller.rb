class TeachersController < ApplicationController
  #Initial teacher main page that lists all teacher names
  def index
    @teachers = Teacher.all
  end
  #After clicking on an initial teacher name,
  #displays all courses a teacher is teaching for all semesters
  def roster
    if validateurl({"name": params[:name]})
      @teachername = params[:name]
      teacherid = Teacher.select("id").where(["name = ?", @teachername]).ids[0].to_s
      @courses = Course.all.where(["teacher_id = ?", teacherid])
    end
  end
  #Displays all students as well as their grades for the course/semester
  def course
    if validateurl({"name": params[:name], "semester": params[:semester], "coursename": params[:course]})
      @semester = params[:semester]
      @coursename = params[:course]
      courseid = Course.select("id").where("name = '" + @coursename + "' AND semester = '" + @semester + "'" ).ids[0].to_s
      @students = ActiveRecord::Base.connection.execute("SELECT grades.grade, students.name FROM grades, students WHERE '" + courseid.to_s + "' = grades.course_id AND '" + @semester.to_s + "' = grades.semester AND students.id = grades.student_id")
    end
  end
  private
    #Validate url parameters via database tables
    #If parameters don't exist, throw 404 error
    def validateurl(myparameters)
      myparameters.each do |columnname, value|
        wheresqlstatement = columnname.to_s + " = '" + value + "'"
        if columnname.to_s == "name"
          existcheck = Teacher.all.where(wheresqlstatement).ids
        elsif columnname.to_s == "coursename"
          existcheck = Course.all.where("name = '" + value + "'").ids
        else
          existcheck = Course.all.where(wheresqlstatement).ids
        end
        #If existcheck has no results, then the url parameter doesn't exist
        if existcheck.size() == 0
          respond_to do |format|
            format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
            format.xml { head :not_found }
            format.any { head :not_found }
          end
          return false
        end
      end
      return true
    end
end
