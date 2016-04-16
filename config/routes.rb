Rails.application.routes.draw do
  post 'samples/upload', to: 'samples#upload'
  get 'samples/fetch', to: 'samples#fetch'
end
