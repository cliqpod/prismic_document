module InternalImageUrl
  def internal_image_url
    "#{PrismicDocument::IMAGE_PROXY_PATH}/#{url.split('/')[3..-1].join('/')}"
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
