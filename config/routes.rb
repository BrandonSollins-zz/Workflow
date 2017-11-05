Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "sign_up#index"
  resources :musicians
  resources :sign_up
  resources :songwriter
  resources :bookings
  post "songwriter/sign_up", to: "songwriter#create"
end
