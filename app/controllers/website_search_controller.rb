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
        extracted_query(params_q_scrubbed),
        @per_page,
        @offset,
        @page,
        on_campus?(ip),
        extracted_scope(params_q_scrubbed)
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
      params[:q] ||= ''
      @q = params_q_scrubbed
      @query = @q
      @per_page = params[:per_page] || 10
      @page = params[:page] || 1
      @offset = (@page.to_i - 1) * @per_page
    end
end
