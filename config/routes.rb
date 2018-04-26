# frozen_string_literal: true

Rails.application.routes.draw do
  mount QuickSearch::Engine => '/'
  mount QuickSearchLibraryWebsiteSearcher::Engine => '/website'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
