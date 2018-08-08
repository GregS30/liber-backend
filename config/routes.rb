Rails.application.routes.draw do
  resources :images
  resources :job_task_images
  resources :jobs
  resources :clients
  resources :projects
  resources :job_tasks
  resources :tasks
  resources :workflows
  resources :scanners
  resources :computers
  resources :users
  resources :skills
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
