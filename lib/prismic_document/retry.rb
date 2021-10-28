class PrismicDocument::Retry
  def self.call(**args, &block)
    new(**args, &block).call
  end

  attr_reader :times, :delay, :block, :default

  def initialize(times: 1, delay: 0, throw_error: false, default: nil, &block)
    @times = times
    @delay = delay
    @block = block
    @default = default
    @retries = 0
  end

  def call
    block.call
  rescue Exception => e
    PrismicDocument::PrismicApi.instance.reload_client
    @retries += 1
    sleep delay if delay.present? && delay.positive?
    retry if @retries <= @times
    raise e
  end
end
