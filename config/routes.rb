Rails.application.routes.draw do

  resources :airports, :only => [:index]
  resources :flights, :only => [:index, :show] do
    resources :snapshots, :only => [:index]
  end

  get '/probability', :to => 'flights#probability'
  get '/prediction', :to => 'flights#prediction'

end
