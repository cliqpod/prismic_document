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
  class Engine < Rails::Engine
    initializer 'local_helper.action_controller' do
      ActiveSupport.on_load :action_controller do
        helper PrismicDocument::ApplicationHelper
      end
    end
  end

  class Configuration
    attr_accessor :api_url, :api_key, :prismic_cdn, :image_proxy_path, :base_controller, :auth
    def initialize
      @api_url = ENV['PRISMIC_URI']
      @api_key = ENV['PRISMIC_KEY']
      @prismic_cdn = ENV['PRISMIC_CDN']
      @image_proxy_path = '/pictures'
      @base_controller = ApplicationController
      @auth = {
          username: ENV["PRISMIC_ADMIN_USERNAME"],
          password: ENV["PRISMIC_ADMIN_PASSWORD"]
      }
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
