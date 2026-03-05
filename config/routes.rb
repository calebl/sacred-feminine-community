Rails.application.routes.draw do
  devise_for :users, controllers: {
    invitations: "admin/invitations"
  }

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root
  authenticated :user do
    root to: "dashboard#show", as: :authenticated_root
  end
  root to: redirect("/users/sign_in")

  # Profiles
  resources :profiles, only: [ :show, :edit, :update ]

  # Account settings (email & password changes)
  namespace :account do
    resource :email, only: [ :edit, :update ]
    resource :password, only: [ :edit, :update ]
  end

  namespace :api do
    resources :map_pins, only: [ :index ]
  end

  # Cohorts
  resources :cohorts do
    resources :cohort_memberships, only: [ :create, :destroy ]
    resources :chat_messages, only: [ :create ]
    resources :posts, only: [ :show, :new, :create, :edit, :update, :destroy ] do
      patch :pin, on: :member
      resources :post_comments, only: [ :create, :destroy ]
    end
  end

  # Groups
  resources :groups do
    resource :group_membership, only: [ :create, :destroy ]
    resources :group_chat_messages, only: [ :create ]
    resources :group_posts, only: [ :show, :new, :create, :edit, :update, :destroy ] do
      patch :pin, on: :member
      resources :group_post_comments, only: [ :create, :destroy ]
    end
  end

  # Notifications
  resource :notifications, only: [ :show ]

  # Direct Messages
  resources :conversations, only: [ :index, :show, :create ] do
    resources :direct_messages, only: [ :create ]
  end

  # Solid Queue dashboard (admin only)
  authenticate :user, ->(user) { user.admin? } do
    mount MissionControl::Jobs::Engine, at: "/admin/jobs"
  end

  # Admin
  namespace :admin do
    get "dashboard", to: "dashboard#show"
    resource :impersonation, only: [ :create, :destroy ]
    resources :announcements
    resources :users, only: [ :index, :update, :destroy ] do
      resource :role, only: [ :update ], module: :users
      resource :invite_link, only: [ :create ], module: :users
    end
  end
end
