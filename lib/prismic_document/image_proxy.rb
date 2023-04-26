require 'rack-proxy'

class PrismicDocument::ImageProxy < Rack::Proxy
  def call(env)
    if env['REQUEST_PATH'] && env['REQUEST_PATH'].index(PrismicDocument.configuration.image_proxy_path) == 0
      super
    else
      @app.call(env)
    end
  end

  def rewrite_env(env)
    prefix = PrismicDocument.configuration.prismic_cdn.split('.').first
    env['REQUEST_PATH'] = env['REQUEST_URI'] = env['PATH_INFO'] = env['ORIGINAL_FULLPATH'] = "/#{prefix}" + env['REQUEST_URI'].gsub(PrismicDocument.configuration.image_proxy_path, '')
    env['HTTP_HOST'] = 'images.prismic.io'
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
