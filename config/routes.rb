Rails.application.routes.draw do
  get "payments/new"
  get "payments/create"
  get "payments/show"
  resources :attendances
  resources :students
  get "home/index"
  resource :session
  resources :passwords, param: :token
  resources :signup, only: %i[new create]
  resources :students
  get "up" => "rails/health#show", as: :rails_health_check
  root "home#index"

  get 'qrcodes', to: 'qrcodes#show'  # Updated route for the QR code
  get 'scan_qr', to: 'qrcodes#scan'

  resources :users, only: [:index, :edit, :update]
  resources :subscriptions, only: [:index, :new, :create, :show]
  resources :payments, only: [:new, :create, :show]
  get 'payment_success', to: 'payments#success'
  get 'payment_failure', to: 'payments#failure'
end
