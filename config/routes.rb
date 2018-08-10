Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      # resources :images
      # resources :job_task_images
      # resources :jobs
      # resources :clients
      # resources :projects
      # resources :job_tasks
      # resources :tasks
      # resources :workflows
      # resources :scanners
      # resources :computers
      # resources :skills

      # Home controller routes.
      root   'home#index'
      get    'auth'            => 'home#auth'

      # Get login token from Knock
      post   'user_token'      => 'user_token#create'

      # User actions
      get    '/users'          => 'users#index'
      get    '/users/current'  => 'users#current'
      post   '/users/create'   => 'users#create'
      patch  '/user/:id'       => 'users#update'
      delete '/user/:id'       => 'users#destroy'

      get   '/filters' => 'filters#index'

    end
  end
end
