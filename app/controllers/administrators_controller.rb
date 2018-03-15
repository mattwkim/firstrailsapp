class AdministratorsController < ApplicationController
  #Refers to the initial administrator page.
  #Lists all administrators' names
  def index
    @administrators = Administrator.all
  end
  #Corresponds to the HTML page for any administrator
  #Displays all semesters worth of data
  def individualview
    @administratorname = params[:name]
    if validateurl({"administratorname": @administratorname}) 
      @semesters = Course.select("DISTINCT(semester)")
    end
  end
  #Displays all courses for a semester
  #Also displays the total number of students enrolled for each course
  def semester
    @chosensemester = params[:semester]
    if validateurl({"semester": @chosensemester, "administratorname": params[:name]})
      @courseinformation = ActiveRecord::Base.connection.execute("SELECT grades.grade, courses.name FROM courses, grades WHERE courses.semester = '" + @chosensemester.to_s + "' AND courses.id = grades.course_id")
      @courseinformation = getenrollmentcounts(@courseinformation)
    end
  end
  #Displays an average grade for the selected course.
  def course
    @chosencourse = params[:course]
    if validateurl({"semester": params[:semester], "name": params[:course], "administratorname": params[:name]})
      courseid = Course.select("id").where(["name = ?", @chosencourse]).ids[0].to_s
      @teachername = Teacher.select("name").where(["course_id = ?", courseid])[0]
      allgrades = Grade.select("grade").where("course_id = '" + courseid + "'")
      #Calculates avg grade by adding all letter grades up and dividing by num of grades
      #Converts an A->4.0, B->3.0, C->2.0, D->1.0, E->0.0
      #If avg results in a decimal, at or above .5 will round the avg grade up
      @avggrade = roundgrade(getavggrade(allgrades))
      @avggrade = convertgradetoletter(@avggrade)
    end
  end
  private
    #Given an avg grade on a numerical scale,
    #round up to the nearest whole integer value if decimal is greater than or equal to .5
    def roundgrade(grade)
      grade = grade.to_s.split(".")
      if grade[1][0].to_f < 5.0
        return grade[0].to_f
      end
      return grade[0].to_f + 1.0
    end
    #Given letter grades, returns an average grade by
    #converting all letter grades to numbers.
    def getavggrade(grades)
      avg = 0.0
      grades.each do |grade|
        if grade.grade == 'A'
          avg += 4.0
        elsif grade.grade == 'B'
          avg += 3.0
        elsif grade.grade == 'C'
          avg += 2.0
        elsif grade.grade == 'D'
          avg += 1.0
        end
      end
      return avg / grades.size()
    end
    #Given a whole integer, return a corresponding letter grade.
    def convertgradetoletter(grade)
      if grade == 4.0
        return 'A'
      elsif grade == 3.0
        return 'B'
      elsif grade == 2.0
        return 'C'
      elsif grade == 1.0
        return 'D'
      end
      return 'E'
    end
    #Helps get enrollment counts by counting the num of grades for a course
    #returns a hash of the key being a course name and the value being its enrollment count
    def getenrollmentcounts(courseinformation)
      courseenrollmentcount = {}
      courseinformation.each do |course|
        if courseenrollmentcount.key?(course['name'])
          courseenrollmentcount[course['name']] += 1
        else
          courseenrollmentcount[course['name']] = 1
        end
      end
      return courseenrollmentcount
    end
    #The purpose of this function is to make sure no one types in invalid parameters
    #The way I have my routes set up, it will accept anything after the /
    #This function will validate what users put in as parameters via the Course database
    #If it doesn't exist, render a 404 error
    def validateurl(myparameters)
      myparameters.each do |columnname, value|
        if columnname.to_s == "administratorname"
          existcheck = Administrator.all.where("name = '" + value + "'").ids
        else
          existcheck = Course.all.where(columnname.to_s + " = '" + value + "'").ids
        end
        #If the url parameters dont exist in the database, size of existcheck should be 0
        #Throw a 404 error
        if existcheck.size() == 0
          respond_to do |format|
            format.html { render :file => "#{Rails.root}/public/404", :layout => false, :status => :not_found }
            format.xml  { head :not_found }
            format.any  { head :not_found }
          end
          return false
        end
      end
      return true
    end
end
