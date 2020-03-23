require 'rack-proxy'

class PrismicDocument::ImageProxy < Rack::Proxy
  def call(env)
    if env['REQUEST_PATH'] && env['REQUEST_PATH'].index(PrismicDocument::IMAGE_PROXY_PATH) == 0
      super
    else
      @app.call(env)
    end
  end

  def rewrite_env(env)
    env['REQUEST_PATH'] = env['REQUEST_URI'] = env['PATH_INFO'] = env['ORIGINAL_FULLPATH'] = env['REQUEST_PATH'].gsub(PrismicDocument::IMAGE_PROXY_PATH, '')
    env['HTTP_HOST'] = PrismicDocument.configuration.prismic_cdn
    env['SERVER_PORT'] = '80'
    env
  end

  def rewrite_response(triplet)
    status, headers, body = triplet

    # delete redundant headers
    headers['content-disposition'] = nil
    headers['content-length'] = nil
    headers['server'] = nil

    triplet
  end
end
