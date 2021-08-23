# frozen_string_literal: true

require 'test_helper'

# Tests for the "loaded_link" method on searchers
class LoadedLinkTest < ActiveSupport::TestCase
  test 'query parameter in loaded_link should be "percent-encoded"' do
    query_term = '"scientific american"'

    # Include both types of URI escaping for now, since either should be safe.

    # URI-escaped with spaces encoded as "%20"
    percent_encoded_query_term = Addressable::URI.escape(query_term)

    # URI-escaped with spaces encoded as "+"
    cgi_escaped_query_term = CGI.escape(query_term)

    # Map of searcher class name to HTTP query parameter holding the
    # query term in loaded_link
    searchers_with_query_param = {
      'QuickSearch::LibAnswersSearcher' => 'q',
      'QuickSearch::LibGuidesDatabaseSearcher' => 'q',
      'QuickSearch::DatabaseFinderSearcher' => 'query',
      'QuickSearch::WorldCatDiscoveryApiSearcher' => 'queryString',
      'QuickSearch::WorldCatDiscoveryApiArticleSearcher' => 'queryString'
    }

    searchers_with_query_param.each_pair do |classname, param_name|
      # Instantiate class
      klass = classname.constantize
      searcher = klass.new(HTTPClient.new, query_term, 3)

      # Get loaded link
      loaded_link = searcher.loaded_link

      expectation_msg = "#{classname}: Expected \"#{loaded_link}\" to include " \
        "\"#{percent_encoded_query_term}\" or \"#{cgi_escaped_query_term}\""

      assert loaded_link.include?("#{param_name}=#{percent_encoded_query_term}") ||
             loaded_link.include?("#{param_name}=#{cgi_escaped_query_term}"), expectation_msg
    end
  end
end
