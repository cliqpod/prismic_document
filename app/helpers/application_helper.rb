module PrismicDocument::ApplicationHelper
  def get_prismic_styles(slice)
    style_classes = []
    style_classes << "slice-#{slice.slice_type}"
    style_classes << "bg-#{slice.non_repeat["background_color"]&.value}" if slice.non_repeat["background_color"]
    style_classes << "type-#{slice.non_repeat["text_type"]&.value}" if slice.non_repeat["text_type"]
    style_classes << "type-#{slice.non_repeat["image_type"]&.value}" if slice.non_repeat["image_type"]
    style_classes << "type-#{slice.non_repeat["list_type"]&.value}" if slice.non_repeat["list_type"]
    style_classes.join(' ').strip
  end
end