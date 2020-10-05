class PrismicDocument::InterlinkService
  class << self
    def setup
      page = 1
      docs = []
      loop do
        options = { 'pageSize' => 100, 'page' => page }
        response = PrismicDocument::PrismicApi.instance.client.all(options)
        page += 1
        docs = docs.concat(response.results)
        break if response.current_page == response.total_pages
      end
      @keywords = docs.map { |x| PrismicDocument::Page.new(object: x, type: x.type) }.reduce(ActiveSupport::OrderedHash.new) do |acc, page|
        keywords = page.keywords&.value&.split(',')&.map(&:strip) || []
        acc.merge(keywords.sort{|x,y| y.length - x.length}.reduce({}) { |obj, kw| obj.merge(kw => page.path.value )})
      end
    end

    def call(match_text)
      PrismicDocument::InterlinkService.keywords.to_h.reduce(match_text || '') do |text, (keyword, path)|
          text.gsub(/(?!<a[^>]*>)(?<!\w)(?<foo>#{Regexp.escape(keyword)})(?!\w)(?![^<]*<\/a>)/i, "<a href=\"#{path}/\">\\k<foo></a>")
      end
    end

    attr_reader :keywords
  end
end