require "RMagick"
include Magick

class Scanimake
  def initialize(stripe_width=1, image_files)
    @images = ImageList.new(*image_files)
    @stripe_width = stripe_width
  end

  def create_layered_image
    layered_image = ImageList.new
    @images.each_with_index do |image, n|
      mask = create_mask(n)
      layered_image << mask.composite(image, 0, 0, SrcInCompositeOp)
    end
    layered_image.flatten_images
  end

  def create_mask_image(width_marge=100, height_marge=10, canvas_color="black")
    create_mask(0, width_marge, height_marge, "white", canvas_color)
  end

  private
  def create_mask(n, width_marge=nil, height_marge=nil, pen_color="black", canvas_color="white")
    #provide a canvas
    width = width_marge ? @images.columns + width_marge : @images.columns
    height = height_marge ? @images.rows + height_marge : @images.rows
    canvas = Image.new(width, height) { self.background_color = canvas_color }

    # provide a pen
    pen = Draw.new
    pen.stroke = pen_color
    pen.stroke_width = @stripe_width
    
    # provide stripes for mask
    offset = n * @stripe_width
    (width/@stripe_width).times do |i|
      next unless (i % @images.length).zero?
      x = i * @stripe_width + offset + @stripe_width/2
      pen.line(x, 0, x, height)
    end
    
    #draw stripes on a canvas
    pen.draw(canvas)

    #make stripes of mask transparent
    masks = ImageList.new { self.alpha = ActivateAlphaChannel }
    masks << canvas
    masks.fx("1-r", AlphaChannel)
  end
end

sm = Scanimake.new(ARGV)
path = File.expand_path(File.dirname(ARGV[0]))
sm.create_layered_image.write("#{path}/out.png")
sm.create_mask_image.write("#{path}/mask_out.png")

exit

