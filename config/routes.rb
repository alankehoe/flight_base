Rails.application.routes.draw do

  resources :flights, :only => [:index, :show] do
    resources :snapshots, :only => [:index]
  end

end
