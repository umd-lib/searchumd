require 'httpclient'

# "Monkey-patching" the HTTPClient class to use system SSL CA certificates,
# instead of the "http_library" built-in CA certificates, which are very old.
#
# See https://github.com/nahi/httpclient/issues/445#issuecomment-931465432
class HTTPClient
  alias original_initialize initialize

  def initialize(*args, &block)
    original_initialize(*args, &block)
    # Force use of the default system CA certs (instead of the 6 year old bundled ones)
    @session_manager&.ssl_config&.set_default_paths
  end
end
