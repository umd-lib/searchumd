# frozen_string_literal: true

Rails.application.routes.draw do
  mount QuickSearch::Engine => '/'
  root to: 'search#index'
  get 'website' => 'website_search#index'
  get 'swiftype' => 'swiftype_search#index'
  get 'opensearch' => 'opensearch#opensearch', :defaults => { format: 'xml' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
