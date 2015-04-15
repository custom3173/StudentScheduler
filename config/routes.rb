Studentscheduler::Application.routes.draw do
  mount Shibbolite::Engine => '/shibbolite'

  resources :students do
    get 'administrators', on: :collection
    resources :schedules
  end

  get 'calendar', to: 'schedules#calendar'
  get 'students/:id/purge', to: 'students#purge_expired_schedules'

  patch '/students/:id/options', to:'students#update_display_options', as: 'options'
  get '/students/:id/mark_tomorrow_absent', to:  'schedules#mark_tomorrow_absent_form'
  post '/students/:id/mark_tomorrow_absent', to: 'schedules#mark_tomorrow_absent'
  root :to => "schedules#calendar"
end
