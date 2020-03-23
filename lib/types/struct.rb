require 'dry-struct'
module PrismicDocument

  module Types
    include Dry.Types()
  end

  class BaseSlice < Dry::Struct
    attribute :name, Types::String
  end

  class TextSlice < BaseSlice
    attribute :text, Types::String
    attribute :text_type, Types::String
    attribute :background_color, Types::String.optional
  end

  class ImageSlice < BaseSlice
    attribute :image_type, Types::String
    attribute :intro_text, Types::String.optional
    attribute :outro_text, Types::String.optional
    # attribute :image
  end

  class Page
    def self.fields(*args)
      args.each do |name|
        define_method name do
          instance_variable_get(:'@object')["#{instance_variable_get(:"@type")}.#{name}"]
        end
      end
    end

    delegate :present?, to: :object
    fields :name, :domain, :path, :title, :description
    attr_reader :object

    def initialize(object:)
      @type = self.class.name.demodulize.split('Page').first.downcase
      @object = object
    end

    def render
      if @object["#{@type}.body"].present?
        ApplicationController.render partial: 'prismic_document/shared/slice', collection: @object["#{@type}.body"].slices
      end
    end
  end

  class StaticPage < Page
    fields :sub_title
  end

  class ArticlePage < Page
    fields :sub_title, :is_featured, :show_comments, :show_social_buttons, :teaser_image, :main_image
  end

  class SearchPage < Page
    fields :title_for_search, :anchors, :default_dict
  end

  class DictionaryPage < Page
    fields :title_for_search, :anchors, :default_dict
  end

  class ListPage < Page
    fields :title_for_search, :anchors, :default_dict, :intro_text
  end

  class ToolPage < Page
    fields :sub_title, :teaser_image, :is_featured
  end

  # router-network types

  class ToolsPage < Page

  end

  class IpPage < Page

  end

  class RouterPage < Page

  end

  class BrandPage < Page

  end
end
