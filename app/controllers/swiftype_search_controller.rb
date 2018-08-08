# frozen_string_literal: true

# "Native" search interface utilizing Swiftype
class SwiftypeSearchController < ApplicationController
  helper QuickSearch::ApplicationHelper
  include QuickSearch::SearcherConcern
  before_action :assign_search_params
  layout 'quick_search/application'

  def index
    # Nothing to do but display the page, which includes the Swiftype
    # JavasScript.
  end

  private

    def assign_search_params
      params[:q] ||= ''
      @q = params_q_scrubbed
      @query = @q
    end
end
