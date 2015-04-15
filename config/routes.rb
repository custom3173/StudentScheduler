Studentscheduler::Application.routes.draw do
  mount Shibbolite::Engine => '/shibbolite'

  resources :students do
    get 'administrators', on: :collection
    resources :schedules
  end

  get 'calendar', to: 'schedules#calendar'
  get 'students/:id/purge', to: 'students#purge_expired_schedules'

  patch '/students/:id/options', to:'students#update_display_options', as: 'options'
  root :to => "schedules#calendar"
end
