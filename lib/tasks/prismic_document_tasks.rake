# desc "Explaining what the task does"
# task :prismic_document do
#   # Task goes here
# end

# frozen_string_literal: true
require 'rest-client'
require 'json'
require 'yaml'


namespace :prismic_document do
  desc 'get all docs from prismic'
  task types: :environment do
    client = Prismic.api(PrismicDocument.configuration.api_url, PrismicDocument.configuration.api_key)

    options = { "pageSize" => 100 }
    response = client.all(options)

    results = []
    response.total_pages.times do |i|
      puts "Response Pagination: #{i}"
      options = { "pageSize" => 100, "page" => i+ 1 }
      results.concat client.all(options).results
    end

    slices = {}
    types = {}
    results.each do |doc|
      if doc.type != "page"
        #Types
        type = {}
        doc.fragments.keys.each do |key|
          type[key] = doc.fragments[key].class.to_s.split("::")[-1]
        end
        if types.key?(doc.type)
          types[doc.type].deep_merge(type)
        else
          types[doc.type] = type
        end

        # Slices
        doc["#{doc.type}.body"].slices.each do |slice|
          slice_hash = {}
          slice_hash = {"non_repeat": {}, "repeat": {}}
          slice.non_repeat.keys.each do |key|
            slice_hash[:non_repeat][key] = slice.non_repeat[key].class.to_s.split("::")[-1]
          end
          slice.repeat[0]&.fragments&.keys&.each do |key|
            slice_hash[:repeat][key] = slice.repeat[0].fragments[key].class.to_s.split("::")[-1]
          end

          if slices.key?(slice.slice_type)
            slices[slice.slice_type].deep_merge(slice_hash)
          else
            slices[slice.slice_type] = slice_hash
          end
        end
      end
    end
    slices_yml = Rails.root.join('config', 'prismic', 'slices.yaml')
    types_yml = Rails.root.join('config', 'prismic', 'types.yaml')
    unless Dir.exists?(Rails.root.join('config', 'prismic'))
      Dir.mkdir(Rails.root.join('config', 'prismic'))
    end
    File.open(slices_yml, "w+") do |f|
      f << slices.to_yaml
    end
    File.open(types_yml, "w+") do |f|
      f << types.to_yaml
    end
  end
  require 'optparse'

  task check_slices: [:environment] do
    options = {
        field: 'data_type'
    }
    option_parser = OptionParser.new
    option_parser.banner = "Usage: rake add [options]"
    option_parser.on("-f", "--field ARG", String) { |num2| options[:field] = num2 }
    args = option_parser.order!(ARGV) {}
    option_parser.parse!(args)
    field = options.values_at(:field)
    page = 1
    docs = []
    loop do
      options = { 'pageSize' => 100, 'page' => page }

      response = PrismicDocument::PrismicApi.instance.client.all(options)
      page += 1
      docs = docs.concat(response.results)
      break if response.current_page == response.total_pages
    end
    docs.each do |doc|
      doc["#{doc.type}.body"]&.slices&.each do |slice|
        if slice.non_repeat[field]
          pp [doc["#{doc.type}.domain"].as_text, doc["#{doc.type}.path"].as_text]
        end
      end
    end
  end
end
