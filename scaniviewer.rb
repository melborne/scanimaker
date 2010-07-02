# ScanAnimator is viewer of a image which create with ScanAnimaker.
Shoes.app do
  IMAGE = ask_open_file
  NUM_IMGS = 5
  MASK_WIDTH = 1
  IMG_WIDTH, IMG_HEIGHT = imagesize(IMAGE)

  background black

  stack :top => 30, :left => 30 do
    @mask = mask do
      (IMG_WIDTH / (MASK_WIDTH*NUM_IMGS) ).ceil.times do |i|
        strokewidth MASK_WIDTH
        stroke white
        x_pos = i*MASK_WIDTH*NUM_IMGS
        line x_pos, 0, x_pos, IMG_HEIGHT
      end
    end
    image IMAGE
  end

  animate 3 do |i|
    @mask.move i%NUM_IMGS, 0
  end
end
