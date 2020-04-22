PrismicDocument::HTMLSerializer = Prismic.html_serializer do |element, html|
  case element
  when Prismic::Fragments::StructuredText::Block::Preformatted
    element.text
  else
    nil
  end
end