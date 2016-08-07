Sparedeck::Application.routes.draw do

  resources :template_decks do
    member do
      get 'rent', to:'template_decks#rent', as:'rent'
    end
  end

  # Authentication routes
  get 'signup/:invitation_token', to: 'users#new', as: 'signup'
  get 'signin', to: 'sessions#new', as: 'signin'
  get 'signout', to: 'sessions#destroy', as: 'signout'

  # Account routes
  get "account", to: "users#account", as: 'account'

  resources :users do
    resources :verification_quizzes, only:[:new, :create]
  end
  resources :sessions
  resources :password_resets
  resources :invitations

  # Static pages
  get 'terms-of-use', to: 'pages#terms', as:'terms'
  get 'contact-us', to: 'pages#contact', as:'contact'
  get 'frequently-asked-questions', to: 'pages#faq', as:'faq'
  get 'how-does-it-work', to: 'pages#about', as:'about'

  resources :card_sets
  resources :cards do
    member do
      get 'order', to:'order_cards#create_or_update', as:'order'
    end
    collection do
      get 'search'
    end
  end

  # Order routes
  get 'returned/:return_token', to:'orders#user_return', as:'user_return'
  get 'cart', to: 'orders#cart', as:'cart'
  get 'clear', to: 'orders#clear_cart', as:'clear_cart'
  resources :orders do
    member do
      patch 'process_schedule'
      get 'payment'
      get 'receipt'
      get 'cancel', action:'cancel', as: 'cancel'
      patch 'authorize_payment'
      post 'coupon_code', action:'coupon_code', as: 'coupon_code'
    end
    resources :order_cards
  end

  # Admin routes
  namespace :admin do
    get "form-elements/:container/:partial", to:'orders#form_partial'

    get 'dashboard', to: 'pages#dashboard', as:'dashboard'
    get 'manage-default-prices', to: 'site_settings#manage_prices', as:'manage_prices'
    resources :verification_quizzes, only:[:show]
    resources :card_sets, :site_settings
    resources :template_decks do
      resources :template_deck_cards
    end
    resources :coupons
    resources :orders do
      resources :order_notes
      resources :stripe_charges
      member do
        get 'receipt'
        get 'cancel', action:'cancel', as: 'cancel'
        get 'shipped_form', action:'shipped_form', as:'shipped_form'
        patch 'shipped', action:'shipped', as:'shipped'
        get 'returned', action:'returned', as:'returned'
      end
      collection do
        get 'status/:status', action:'index', as:'status'
      end
    end
    resources :stripe_charges do
      member do
        get 'refund', action:'refund', as:'refund'
      end
    end
    resources :cards do
      collection do
        get 'search'
      end
    end
    resources :users do
      member do
        get 'toggle_admin'
      end
    end
  end

  root 'pages#home'

end
