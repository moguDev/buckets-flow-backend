Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations: 'api/v1/auth/registrations'
      }
      resources :buckets, only: [:index, :create] do
        collection do
          get :show_buckets
          get :destroy_backdate
        end
      end
    end
  end
end