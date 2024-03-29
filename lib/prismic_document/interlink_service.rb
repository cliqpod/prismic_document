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

      @keywords = docs.map { |x| PrismicDocument::Page.new(object: x, type: x.type) }.group_by { |x| x.domain&.value }.select { |x, _| x.present? }.reduce(ActiveSupport::OrderedHash.new) do |acc, (domain, pages)|
        words = pages.reduce({}) do |kwords, page|
          keywords = page.keywords&.value&.split(',')&.map(&:strip) || []
          kwords.merge(keywords.sort{|x,y| y.length - x.length}.reduce({}) { |obj, kw| obj.merge(kw => page.path.value )})
        end
        acc.merge(domain => Hash[words.sort_by {|k, _| -k.length }])
      end
    end

    def call(match_text, ignore_path: nil, domain: nil)
      host = domain.split('.').last(2).join('.')
      PrismicDocument::InterlinkService.keywords[host].to_h.reduce(match_text || '') do |text, (keyword, path)|
        if path == ignore_path || (path == '/tools/word-counter' && domain.include?('wordcounter'))
          text
        else
          doc = Nokogiri::HTML::fragment(text)
          doc.search('.//text()[not(ancestor::h1 or ancestor::h2 or ancestor::h3 or ancestor::h4 or ancestor::h5 or ancestor::h6)]').select { |x| x.content.present? }.each do |node|
            next if node.parent&.name == 'a'
            node.replace(node.content.gsub(/(?!<(a|h1|h2|h3|h4|h5|h6|a)[^>]*>)(?<!\w)(?<foo>#{Regexp.escape(keyword)})(?!\w)(?![^<]*<\/(a|h1|h2|h3|h4|h5|h6)>)/i, "<a href=\"#{path.chomp('/')}/\">\\k<foo></a>"))
          end

          doc.to_html
        end
      end
    end

    attr_reader :keywords
  end
end
