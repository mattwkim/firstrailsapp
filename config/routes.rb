Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'teacher/*name/*course/*semester' => 'teachers#course'
  get 'teacher/*name' => 'teachers#roster'
  get 'teacher' => 'teachers#index'
  get 'student/*name/*semester' => 'students#semester'
  get 'student/*name' => 'students#individualview'
  get 'student' => 'students#index'
  get 'administrator' => 'administrators#index'
  get 'administrator/*name/*semester/*course' => 'administrators#course'
  get 'administrator/*name/*semester' => 'administrators#semester'
  get 'administrator/*name' => 'administrators#individualview'
end
