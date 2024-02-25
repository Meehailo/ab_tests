Rails.application.routes.draw do
  resources :statistics, only: %i[index]
  resources :experiments, only: %i[index]
end
