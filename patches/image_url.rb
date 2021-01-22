module InternalImageUrl
  def internal_image_url
    "#{PrismicDocument.configuration.image_proxy_path}/#{URI.decode(url).split('/').last}"
  end
end

module Prismic
  module Fragments
    class Image < Fragment
      include InternalImageUrl

      class View < Fragment
        include InternalImageUrl
      end
    end
  end
end
