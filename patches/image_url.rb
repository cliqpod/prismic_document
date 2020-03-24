module InternalImageUrl
  def internal_image_url
    "#{PrismicDocument.configuration.image_proxy_path}/#{url.split('/')[4..-1].join('/')}"
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
