PrismicDocument::HTMLSerializer = lambda do |domain|
  Prismic.html_serializer do |element, html|
    link_resolver ||= nil
    case element
    when Prismic::Fragments::StructuredText::Block::Preformatted
      element.text
    when Prismic::Fragments::StructuredText::Span::Hyperlink
      link = element.link
      if link.is_a?(Prismic::Fragments::DocumentLink) && link.broken
        "<span>#{html}</span>"
      else
        target_value = link.target || '_blank' unless link.url.include? domain
        target = target_value.nil? ? "" : 'target="' + target_value + '" rel="noopener"'
        %(<a href="#{link.url(link_resolver)}" #{target}>#{html}</a>)
      end
    else
      nil
    end
  end
end
