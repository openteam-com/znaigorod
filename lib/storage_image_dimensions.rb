class StorageImageDimensions
  attr_accessor :height, :width

  def initialize(url)
    if url.match(/files\/\d+\/(\d+)-(\d+)/)
      @width, @height = url.match(/files\/\d+\/(\d+)-(\d+)/).to_a[1..-1].map(&:to_i)
    else
      @width, @height = FastImage.size(url)
    end
  end

  def dimensions
    [width, height].join('x')
  end
end
