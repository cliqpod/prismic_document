module Prismic
  module JsonParser
    class << self
      def parsers
        @parsers ||= {
            'Link.document'  => method(:document_link_parser),
            'Text'           => method(:text_parser),
            'Link.web'       => method(:web_link_parser),
            'Link.image'     => method(:image_link_parser),
            'Link.file'      => method(:file_link_parser),
            'Date'           => method(:date_parser),
            'Timestamp'      => method(:timestamp_parser),
            'Number'         => method(:number_parser),
            'Embed'          => method(:embed_parser),
            'GeoPoint'       => method(:geo_point_parser),
            'Image'          => method(:image_parser),
            'Color'          => method(:color_parser),
            'StructuredText' => method(:structured_text_parser),
            'Select'         => method(:select_parser),
            'Multiple'       => method(:multiple_parser),
            'Group'          => method(:group_parser),
            'SliceZone'      => method(:slices_parser),
            'Separator'      => method(:separator_parser),
            'IntegrationFields' => method(:integration_fields_parser),
            'Boolean' => ->(json) { json['value'] }
        }
      end
    end
  end
end
