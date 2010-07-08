require "RMagick"
include Magick

class Scanimake
  def initialize(stripe_width=1, image_files)
    @images = ImageList.new(*image_files)
    @stripe_width = stripe_width
  end

  def create_layered_image(direction=:vertical)
    layered_image = ImageList.new
    @images.each_with_index do |image, n|
      mask = create_mask(n, direction)
      layered_image << mask.composite(image, 0, 0, SrcInCompositeOp)
    end
    layered_image.flatten_images
  end

  def create_mask_image(direction=:vertical, width_marge=100, height_marge=10, canvas_color="black")
    create_mask(0, direction, width_marge, height_marge, "white", canvas_color)
  end

  private
  def create_mask(n, direction, width_marge=nil, height_marge=nil, pen_color="black", canvas_color="white")
    #provide a canvas
    width = width_marge ? @images.columns + width_marge : @images.columns
    height = height_marge ? @images.rows + height_marge : @images.rows
    canvas = Image.new(width, height) { self.background_color = canvas_color }

    # provide a pen
    pen = Draw.new
    pen.stroke = pen_color
    pen.stroke_width = @stripe_width
    
    # provide stripes for mask
    case direction
    when :vertical
      number_of_stripes = width/@stripe_width
      line_proc = lambda { |x| pen.line(x, 0, x, height) }
    when :horizontal
      number_of_stripes = height/@stripe_width
      line_proc = lambda { |x| pen.line(0, x, width, x) }
    else
      raise "Direction must :vertical or :horizontal"
    end
    offset = n * @stripe_width
    number_of_stripes.times do |i|
      next unless (i % @images.length).zero?
      pos = i * @stripe_width + offset + @stripe_width/2
      line_proc[pos]
    end
    
    #draw stripes on a canvas
    pen.draw(canvas)

    #make stripes of mask transparent
    masks = ImageList.new { self.alpha = ActivateAlphaChannel }
    masks << canvas
    masks.fx("1-r", AlphaChannel)
  end
end

if __FILE__ == $0
  sm = Scanimake.new(ARGV)
  path = File.expand_path(File.dirname(ARGV[0]))
  sm.create_layered_image(:horizontal).write("#{path}/ball.png")
  sm.create_mask_image(:horizontal).write("#{path}/mask_ball.png")
  exit
end

