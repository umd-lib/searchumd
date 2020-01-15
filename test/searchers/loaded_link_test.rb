# frozen_string_literal: true

require 'test_helper'

# Tests for the "loaded_link" method on searchers
class LoadedLinkTest < ActiveSupport::TestCase
  test 'query parameter in loaded_link should be "percent-encoded"' do
    query_term = '"scientific american"'

    percent_encoded_query_term = CGI.escape(query_term)

    # Map of searcher class name to HTTP query parameter holding the
    # query term in loaded_link
    searchers_with_query_param = {
      'QuickSearch::LibAnswersSearcher' => 'q',
      'QuickSearch::DatabaseFinderSearcher' => 'query',
      'QuickSearch::LibraryWebsiteSearcher' => 'query',
      'QuickSearch::WorldCatDiscoveryApiSearcher' => 'queryString',
      'QuickSearch::WorldCatDiscoveryApiArticleSearcher' => 'queryString'
    }

    searchers_with_query_param.each_pair do |key, value|
      # Instantiate class
      klass = key.constantize
      searcher = klass.new(HTTPClient.new, query_term, 3)

      # Get loaded link
      loaded_link = searcher.loaded_link

      expected_param = "#{value}=#{percent_encoded_query_term}"
      assert loaded_link.include?(expected_param), "Failed for #{key}, loaded_link=#{loaded_link}"
    end
  end
end
