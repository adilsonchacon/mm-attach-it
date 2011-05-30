require 'RMagick'

class Storage

  def resize(style_value = nil, filename = nil)
    new_image = Magick::Image.read(filename).first
    new_image.change_geometry!(style_value) { |cols, rows, img| img.resize!(cols, rows) }
  end

end
