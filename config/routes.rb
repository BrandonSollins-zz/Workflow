Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "sign_up#index"
  resources :musicians
  resources :sign_up
  resources :songwriter
  resources :bookings
  post "songwriter/sign_up", to: "songwriter#create"
  get "bookings/:id", to: "bookings#show"
  get "bookings/status/:id", to: "bookings#show_status"
  get "b/:id/sr", to: "bookings#studio_reject"
  get "b/:id/sc", to: "bookings#studio_confirm"
  get "b/:id/mr", to: "bookings#musician_reject"
  get "b/:id/mc", to: "bookings#musician_confirm"
end
