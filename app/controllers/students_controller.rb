class StudentsController < ApplicationController
  #Corresponds to the main student page
  #displays a list of all students' names
  def index
    @students = Student.all
  end
  #Displays all semesters a student has taken or
  #is enrolled in classes for
  def individualview
    if validateurl({'studentname': params[:name]})
      @studentname = params[:name]
      studentid = Student.select("id").where("name = '" + @studentname + "'").ids[0].to_s
      @semesters = Grade.select("DISTINCT(semester)").where("student_id = '" + studentid + "'")
    end
  end
  #Displays all courses and grades for the semester
  #as well as GPA for the semester
  def semester
    if validateurl({"semester": params[:semester], 'studentname': params[:name]})
      @currentsemester = params[:semester]
      studentid = Student.select("id").where("name = '" + params[:name] + "'").ids[0].to_s
      @courseinformation = ActiveRecord::Base.connection.execute("SELECT courses.name, grades.grade FROM courses, grades WHERE grades.student_id = '" + studentid + "' AND grades.course_id = courses.id AND courses.semester = '" + @currentsemester + "'")
      #Display GPA with two decimal points for consistency
      @semestergpa = '%.2f' % gpacalculate(@courseinformation)
    end
  end
  private
    #Returns the average grade on a numerical scale.
    def gpacalculate(courseinfo)
      yourgpa = 0.0
      courseinfo.each do |course|
        if course['grade'] == 'A'
          yourgpa += 4.0
        elsif course['grade'] == 'B'
          yourgpa += 3.0
        elsif course['grade'] == 'C'
          yourgpa += 2.0
        elsif course['grade'] == 'D'
          yourgpa += 1.0
        end
      end
      return yourgpa / courseinfo.size()
    end
    #Validates the url parameters a user enters by checking via the database
    #If any don't exist, throw a 404 erro
    def validateurl(myparameters)
      myparameters.each do |columnname, value|
        if columnname.to_s == "studentname"
          existcheck = Student.all.where("name = '" + value + "'").ids
        else
          existcheck = Grade.all.where(columnname.to_s + " = '" + value + "'").ids
        end
        #If existcheck has no results, then the url parameter doesn't exist.
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
