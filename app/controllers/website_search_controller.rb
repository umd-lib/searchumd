# frozen_string_literal: true

class WebsiteSearchController < ApplicationController
  helper QuickSearch::ApplicationHelper
  include QuickSearch::SearcherConcern
  before_action :assign_search_params
  layout 'quick_search/application'

  def index
    do_search
    @results = Kaminari.paginate_array(@searcher.results, total_count: @searcher.total)
                       .page(@page).per(@per_page)
  end

  private

    def do_search
      @searcher = QuickSearch::LibraryWebsiteSearcher.new(
        http_client,
        extracted_query(@q),
        @per_page,
        @offset,
        @page,
        on_campus?(ip),
        extracted_scope(@q)
      )
      @searcher.search
    end

    def http_client
      HTTPClient.new
    end

    def ip
      request.remote_ip
    end

    def assign_search_params
      # For library website search, query parameter is "query", not "q"
      # This is so the query parameter is compatible with what is used in Hippo.
      params[:query] ||= ''
      @q = params[:query].scrub
      @query = @q
      @per_page = params[:per_page] || 10
      @page = params[:page] || 1
      @offset = (@page.to_i - 1) * @per_page
    end
end
