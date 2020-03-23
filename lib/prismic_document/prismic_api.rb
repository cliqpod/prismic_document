require 'singleton'

class PrismicDocument::PrismicApi
  include Singleton

  class << self
    delegate :by_document_type, :by_path, :get_values_by_type, :reload_client, to: :instance
  end


  attr_accessor :client
  delegate_missing_to :@client

  def initialize
    @client = Prismic.api(PrismicDocument.configuration.api_url, access_token: PrismicDocument.configuration.api_key)
  end

  def by_document_type(request_domain, doc_type)
    PrismicDocument::Retry.call(default: []) do
      query([
                Prismic::Predicates.at('document.type', doc_type.to_s),
                Prismic::Predicates.at("my.#{doc_type}.domain", request_domain)
            ],
            'orderings' => '[document.first_publication_date desc]').results
    end
  end

  def by_path(request_domain, doc_type, path)
    PrismicDocument::Retry.call(default: nil) do
      doc = query([Prismic::Predicates.at("my.#{doc_type}.domain", request_domain), Prismic::Predicates.at("my.#{doc_type}.path", path.to_s)]).results&.first
      "PrismicDocument::#{doc_type.capitalize}Page".constantize.new(object: doc)
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
