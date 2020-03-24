class PrismicDocument::PrismicController < PrismicDocument.configuration.base_controller
  before_action :authenticate
  before_action :set_background, only: :types
  def index
    client = Prismic.api(ENV['PRISMIC_URI'], ENV['PRISMIC_KEY'])

    options = { "pageSize" => 100 }
    response = client.all(options)

    @docs = []
    response.total_pages.times do |i|
      puts "Response Pagination: #{i}"
      options = { "pageSize" => 100, "page" => i+ 1 }
      @docs.concat client.all(options).results
    end
    @docs.sort_by!{|doc| [doc.type, (doc.fragments["domain"]&.as_text || "nothing"), doc.first_publication_date]}
    @docs = @docs.select do |elem|
      elem.type != "page"
    end
  end

  def types
    file = Rails.root.join('config', 'prismic', 'types.yaml')
    @code = if File.exists?(file)
      CodeRay.scan(File.read(file), :yaml).div
    else
      ''
    end
  end

  protected

  def set_background
    @background = 'lightgray'
  end

  def authenticate
    logged_in = authenticate_with_http_basic do |u, p|
      auth = PrismicDocument.configuration.auth
      u == auth[:username] && p == auth[:password]
    end
    request_http_basic_authentication unless logged_in
  end
end