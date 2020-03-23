require 'prismic'
%w[
  version
  railtie
  retry
  prismic_api
  image_proxy
].each { |r| require "prismic_document/#{r}" }
require 'types/struct'
require_relative '../app/helpers/application_helper'
require_relative '../patches/boolean'
require_relative '../patches/image_url'

module PrismicDocument
  IMAGE_PROXY_PATH = '/pictures'
  class Engine < Rails::Engine
    initializer 'local_helper.action_controller' do
      ActiveSupport.on_load :action_controller do
        helper PrismicDocument::ApplicationHelper
      end
    end
  end

  class Configuration
    attr_accessor :api_url, :api_key, :prismic_cdn
    def initialize
      @api_url = ENV['PRISMIC_URI']
      @api_key = ENV['PRISMIC_KEY']
      @prismic_cdn = ENV['PRISMIC_CDN']
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
