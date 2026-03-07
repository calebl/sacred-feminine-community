Rails.application.routes.draw do
  devise_for :users, controllers: {
    invitations: "admin/invitations"
  }

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

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
    resource :vapid_key, only: [ :show ]
  end

  # Push notification subscriptions
  resources :push_subscriptions, only: [ :create, :destroy ]

  # Cohorts
  resources :cohorts do
    resources :cohort_memberships, only: [ :create, :destroy ]
    resources :posts, only: [ :show, :create, :edit, :update, :destroy ] do
      resource :pin, only: [ :update ], module: :posts
      resources :post_comments, only: [ :create, :destroy ]
    end
  end

  # Groups
  resources :groups do
    resource :group_membership, only: [ :create, :destroy ]
    resources :group_posts, only: [ :show, :create, :edit, :update, :destroy ] do
      resource :pin, only: [ :update ], module: :group_posts
      resources :group_post_comments, only: [ :create, :destroy ]
    end
  end

  # Feed (public posts for all authenticated members)
  resources :feed_posts, path: "feed", only: [ :index, :show, :create, :edit, :update, :destroy ] do
    resource :pin, only: [ :update ], module: :feed_posts
    resources :feed_post_comments, only: [ :create, :destroy ]
  end

  # FAQs (admin-managed from dashboard)
  resources :faqs, only: [ :index, :create, :edit, :update, :destroy ]

  # Mention search (for @mention autocomplete)
  resources :mention_searches, only: [ :index ]

  # Reactions (polymorphic - works for all post and comment types)
  resources :reactions, only: [ :create, :update, :destroy ]

  # Notifications
  resource :notifications, only: [ :show ]

  # Direct Messages
  namespace :conversations do
    resources :member_searches, only: [ :index ]
  end

  resources :conversations, only: [ :index, :show, :new, :create ] do
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
