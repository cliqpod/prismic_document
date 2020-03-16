%w[
  version
  railtie
  retry
  prismic_api
].each { |r| require "prismic_document/#{r}" }

module PrismicDocument
end
