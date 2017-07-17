Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :musicians, path: "/workflow/musicians"
  resources :sign_up, path: "/workflow/sign_up"
end
