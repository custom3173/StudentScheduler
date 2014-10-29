Studentscheduler::Application.routes.draw do

  resources :students, :schedules

  resources :students do
    resources :schedules
  end

  get 'calendar', to: 'schedules#calendar'
  get 'students/:id/purge', to: 'students#purge_expired_schedules'
  get 'administrators', to: 'students#administrators'
  get 'logout', to: 'application#unload_session'
  get '/students/:id/mark_tomorrow_absent', to:  'schedules#mark_tomorrow_absent_form'
  post '/students/:id/mark_tomorrow_absent', to: 'schedules#mark_tomorrow_absent'
  root :to => "schedules#calendar"
end
