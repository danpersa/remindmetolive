RemindMeToLive::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  root                                  :to => 'pages#home'
  match '/signup',                      :to => 'users#new'
  match '/activate',                    :to => 'users#activate'
  match '/signin',                      :to => 'sessions#new'
  match '/signout',                     :to => 'sessions#destroy'

  match '/contact',                     :to => 'pages#contact'
  match '/about',                       :to => 'pages#about'
  match '/help',                        :to => 'pages#help'
  match '/reset-password-mail-sent',    :to => 'pages#reset_password_mail_sent',
                                        :as => 'reset_password_mail_sent'

  match '/follow',                      :to => 'users#follow',
                                        :via => :post,
                                        :as => 'follow'

  match '/follow',                      :to => 'users#unfollow',
                                        :via => :delete,
                                        :as => 'unfollow'

  match '/remind-me-too/:id',           :to => 'user_ideas#new_for_existing_idea',
                                        #:constraints => { :idea_id => /[0-9]+/ },
                                        :as => 'new_for_existing_idea'

  resources :sessions, :only => [:new, :create, :destroy]
  resources :users do
    member do
      get :following, :followers
    end
    resource :profile, :only => [:edit, :create],
             :path_names => {:edit => ''},
             :as => :profile
  end


  resources :ideas, :only => [:show, :create, :update, :destroy] do
    member do
      # the list of users that shares the idea
      get :users
      get :followed_users, :path => 'followed-users'
    end
  end

  resources :user_ideas, :only => [:index, :show, :create, :update, :destroy],
            :path => 'ideas-to-remember'

  resources :idea_lists, :only => [:index, :show, :new, :create, :edit, :update, :destroy],
            :path => 'idea-lists' do
    member do
      post :add_idea, :path => 'add-idea'
    end
  end

  match '/good-ideas/:id',      :to => 'good_ideas#create',
                                :via => :post,
                                :as => 'good_idea_create'

  resources :good_ideas,
            :path => 'good-ideas',
            :only => [:destroy],
            :as => 'good_ideas'

  match '/done-ideas/:id',      :to => 'done_ideas#create',
                                :via => :post,
                                :as => 'done_idea_create'

  resources :done_ideas,
            :path => 'done-ideas',
            :only => [:destroy],
            :as => 'done_ideas'


  resources :reset_passwords,
            :path => 'reset-password',
            :only => [:new, :create],
            # the new path is the same as the create path
            :path_names => {:new => ''}

  resources :change_reseted_passwords,
            :path => 'change-reseted-password',
            :only => [:edit, :create],
            # the edit path is the same as the create path
            :path_names => {:edit => ''}

  resources :change_passwords,
            :path => 'change-password',
            :only => [:new, :create],
            # the new path is the same as the create path
            :path_names => {:new => ''}

  root                                  :to => 'prototype#first'
  match '/first',                       :to => 'prototype#first'
  match '/second',                      :to => 'prototype#second'
  match '/third',                       :to => 'prototype#third'
  match '/forms',                       :to => 'prototype#forms'
  match '/login-form',                  :to => 'prototype#login_form'
  match '/navbar',                      :to => 'prototype#navbar'
  match '/news-feed-page',              :to => 'prototype#news_feed'

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
