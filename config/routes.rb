SensorCloud::Application.routes.draw do


  resources :users do
    member do
      get 'edit/edit_profile' => 'users#profile'
      get 'streams' => 'streams#index'
      # get 'following' => 'users#following', as: :following
      get 'following' => 'users#following'
    end
  end
  resources :users do
    resources :vstreams
  end  

  resources :streams do
    collection do
      get '/'                  => :get_streams
      get '/new_from_resource' => :new_from_resource
      delete '/'               => :destroyAll
    end
  end

  # resources :vstreams
  resources :searches
	resources :sessions, only: [:new, :create, :destroy]
  resources :contacts, only: [:new, :create]

  root  'static_pages#home'


  get '/vsdatapoints/:id' => 'vstreams#fetch_datapoints'
  post '/users/:user_id/vstreams/create2' => 'vstreams#create2'


  post '/relationships/unfollow' => 'relationships#destroy'
  post '/relationships/follow'   => 'relationships#create'

  get '/resources/:id'  => 'streams#fetchResource'
  get '/suggest/:model' => 'streams#suggest'
  get '/datapoints/:id' => 'streams#fetch_datapoints'
  get '/prediction/:id' => 'streams#fetch_prediction'
  post '/preview'   => 'streams#fetch_datapreview'

  get '/filter'         => 'searches#filter'
  get '/autocomplete'   => 'searches#fetch_autocomplete'
  get '/history'        => 'searches#fetch_graph_data'
  put '/userranking'    => 'searches#update_user_ranking'
  post '/get_more_info' => 'searches#create'

  get '/signup'     => 'users#new'
  get '/signin'     => 'sessions#new'
  delete '/signout' => 'sessions#destroy'

  get '/terms'    => 'static_pages#terms'
  get '/privacy'  => 'static_pages#privacy'
  get '/security' => 'static_pages#security'
  get '/api'      => 'static_pages#api'
  get '/faq'      => 'static_pages#faq'
  get '/manual'   => 'static_pages#manual'
  get '/help'     => 'static_pages#help'
  get '/about'    => 'static_pages#about'


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
