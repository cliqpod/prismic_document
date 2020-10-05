PrismicDocument::TextHTMLSerializer = lambda do |domain, link_resolver = nil|
  Prismic.html_serializer do |element, html|
    case element
    when Prismic::Fragments::StructuredText::Block::Preformatted
      element.text
    when Prismic::Fragments::StructuredText::Span::Hyperlink
      link = element.link
      if link.is_a?(Prismic::Fragments::DocumentLink)
        return "<span>#{html}</span>" if link.broken
        %(<a href="#{link.url(link_resolver)}">#{html}</a>)
      else
        target_value = link.target || '_blank' unless link.url.include? domain
        target = target_value.nil? ? "" : 'target="' + target_value + '" rel="nofollow"'
        %(<a href="#{link.url}" #{target}>#{html}</a>)
      end
    else
      nil
    end
  end
end

PrismicDocument::HTMLSerializer = lambda do |domain, link_resolver = nil|
  Prismic.html_serializer do |element, html|
    case element
    when Prismic::Fragments::StructuredText::Span::Hyperlink
      link = element.link
      if link.is_a?(Prismic::Fragments::DocumentLink)
        return "<span>#{html}</span>" if link.broken
        %(<a href="#{link.url(link_resolver)}">#{html}</a>)
      else
        target_value = link.target || '_blank' unless link.url.include? domain
        target = target_value.nil? ? "" : 'target="' + target_value + '" rel="nofollow"'
        %(<a href="#{link.url}" #{target}>#{html}</a>)
      end
    end
  end
end
