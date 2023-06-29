Rails.application.routes.draw do
  devise_for :users

  root 'products#index'

  resources :payments, only: %i[index show new create] do
    get '3ds', to: 'payments#approve_form'
  end

  resources :payouts, only: %i[index show new create]

  get 'api/v1/payments/success/:id', to: 'payments#success'
  get 'api/v1/payments/declined/:id', to: 'payments#declined'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      namespace :payments do
        post '/success/:id', to: 'callback#success'
        post '/declined/:id', to: 'callback#declined'
        post '/callback/:id', to: 'callback#callback'
      end
    end
  end
end
