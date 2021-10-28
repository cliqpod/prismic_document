# frozen_string_literal: true

require 'singleton'

class PrismicDocument::PrismicApi
  include Singleton

  class << self
    delegate :by_document_type, :by_document_type_and_locale, :by_path, :by_path_and_locale,
             :by_key, :by_key_and_locale, :get_values_by_type, :reload_client, to: :instance
  end

  attr_accessor :client
  delegate_missing_to :@client

  def initialize
    opts = {
        access_token: PrismicDocument.configuration.api_key,
    }
    opts[:cache] = PrismicDocument.configuration.cache if PrismicDocument.configuration.cache
    opts[:api_cache] = PrismicDocument.configuration.cache if PrismicDocument.configuration.api_cache
    @client = Prismic.api(PrismicDocument.configuration.api_url, opts)
  end

  def by_document_type(request_domain, doc_type, options: {})
    PrismicDocument::Retry.call(default: []) do
      query([
              Prismic::Predicates.at('document.type', doc_type.to_s),
              Prismic::Predicates.at("my.#{doc_type}.domain", request_domain)
            ],
            { 'pageSize' => 100, 'orderings' => '[document.first_publication_date desc]' }
                .merge(options)).results.map { |x| PrismicDocument::Page.new(object: x, type: doc_type) }
    end
  end

  def by_document_type_without_domain(doc_type, options: {})
    PrismicDocument::Retry.call(default: []) do
      query([
              Prismic::Predicates.at('document.type', doc_type.to_s),
            ],
            { 'pageSize' => 100, 'orderings' => '[document.first_publication_date desc]' }
              .merge(options)).results.map { |x| PrismicDocument::Page.new(object: x, type: doc_type) }
    end
  end

  def by_document_type_and_locale(request_domain, doc_type, locale = 'en', options: {})
    PrismicDocument::Retry.call(default: []) do
      query([
              Prismic::Predicates.at('document.type', doc_type.to_s),
              Prismic::Predicates.at("my.#{doc_type}.domain", request_domain)
            ],
            { 'pageSize' => 100, 'lang' => locale.to_s, 'orderings' => '[document.first_publication_date desc]' }
            .merge(options))
        .results.map { |x| PrismicDocument::Page.new(object: x, type: doc_type) }
    end
  end

  def by_path(request_domain, doc_type, path)
    PrismicDocument::Retry.call(default: nil) do
      doc = query([Prismic::Predicates.at("my.#{doc_type}.domain", request_domain),
                   Prismic::Predicates.at("my.#{doc_type}.path", path.to_s)],
                  'fetchLinks' => 'author.name, author.bio, author.image').results&.first
      PrismicDocument::Page.new(object: doc, type: doc_type)
    end
  end

  def by_path_and_locale(request_domain, doc_type, path, locale = 'en')
    PrismicDocument::Retry.call(default: nil) do
      doc = query([
                    Prismic::Predicates.at("my.#{doc_type}.domain", request_domain),
                    Prismic::Predicates.at("my.#{doc_type}.path", path.to_s)
                  ], 'fetchLinks' => 'author.name, author.bio, author.image',
                     'lang' => locale.to_s).results&.first
      PrismicDocument::Page.new(object: doc, type: doc_type)
    end
  end

  def by_key(request_domain, doc_type, uid)
    PrismicDocument::Retry.call(default: nil) do
      doc = query([Prismic::Predicates.at("my.#{doc_type}.domain", request_domain),
                   Prismic::Predicates.at("my.#{doc_type}.uid", uid)],
                  'fetchLinks' => 'author.name, author.bio, author.image').results&.first
      PrismicDocument::Page.new(object: doc, type: doc_type)
    end
  end

  def by_key_and_locale(request_domain, doc_type, uid, locale = 'en')
    PrismicDocument::Retry.call(default: nil) do
      doc = query([
                    Prismic::Predicates.at("my.#{doc_type}.domain", request_domain),
                    Prismic::Predicates.at("my.#{doc_type}.uid", uid)
                  ], 'fetchLinks' => 'author.name, author.bio, author.image',
                     'lang' => locale.to_s).results&.first

      PrismicDocument::Page.new(object: doc, type: doc_type)
    end
  end

  def get_values_by_type(domain, type, field_name)
    results = query(Prismic::Predicates.any("my.#{type}.domain", [domain])).results
    field_names = []
    results.each do |document|
      field_names << document["#{type}.#{field_name}"].as_text
    end
    field_names
  end

  def reload_client
    initialize
  end
end
