SensorCloud::Application.routes.draw do

  get "vstreams/index"
  resources :users do   
      resources :vstreams
  end    

  resources :streams do
    collection do
      get '/new_from_resource', :to => :new_from_resource
      delete '/',               :to => :destroyAll
    end
  end

  resources :vstreams
  resources :searches
	resources :sessions, 			only: [:new, :create, :destroy]
  resources :contacts, 			only: [:new, :create]

  root  'static_pages#home'

  match '/relationships/unfollow', to: 'relationships#custom_destroy',    via: 'post'
  match '/relationships/follow',     to: 'relationships#custom_create',     via: 'post'

  match '/resources/:id',  to: 'streams#fetchResource',    via: 'get'
  match '/suggest/:model', to: 'streams#suggest',          via: 'get'
  match '/datapoints/:id', to: 'streams#fetch_datapoints', via: 'get'
  match '/prediction/:id', to: 'streams#fetch_prediction', via: 'get'
  match '/vsdatapoints/:id', to: 'vstreams#fetch_datapoints', via: 'get'
  match '/signup',    to: 'users#new',            via: 'get'
	match '/signin', 		to: 'sessions#new',					via: 'get'
	match '/signout',		to: 'sessions#destroy',			via: 'delete'

  match '/get_more_info',  to: 'searches#create',    via: 'post'
  match '/terms',    to: 'static_pages#terms',        via: 'get'
  match '/privacy',  to: 'static_pages#privacy',      via: 'get'
  match '/security', to: 'static_pages#security',     via: 'get'
  match '/api',      to: 'static_pages#api',          via: 'get'
  match '/faq',      to: 'static_pages#faq',          via: 'get'
  match '/manual',   to: 'static_pages#manual',       via: 'get'
  match '/help',     to: 'static_pages#help',         via: 'get'
  match '/about',    to: 'static_pages#about',        via: 'get'
  match '/vstreams/create2', to: 'vstreams#create2',  via: 'post'

  match '/filter',       to: 'searches#filter',              via: 'get'
  match '/userranking',  to: 'searches#update_user_ranking', via: 'put'
  match '/autocomplete', to: 'searches#fetch_autocomplete',  via: 'get'
  match '/history',      to: 'searches#fetch_graph_data',    via: 'get'

  # get "vstreams/new_vstream" => 'vstreams#new_vstream', :as => :new_vstream

  
	get 'users/:username/following' => 'users#following', as: :following

  get '/users/:username/edit/edit_profile' => 'users#profile'
  get '/users/:username/streams' => 'streams#index'
  post '/users/:user_id/vstreams/create2' => 'vstreams#create2'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
