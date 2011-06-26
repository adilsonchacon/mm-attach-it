require 'RMagick'

class Storage

  def transform(style_value = nil, filename = nil)
    style_value.gsub!(/\s+/, '')

    if style_value.match(/^(\d+)x(\d+)\#$/)
      crop($1.to_i, $2.to_i, filename)
    else
      resize(style_value, filename)
    end
  end

  private
  def resize(style_value = nil, filename = nil)
    new_image = Magick::Image.read(filename).first
    new_image.change_geometry!(style_value) { |cols, rows, img| img.resize!(cols, rows) }
    new_image
  end

  def crop(new_width = nil, new_height = nil, filename = nil)
    new_image = Magick::Image.read(filename).first
    width = new_image.columns
    height = new_image.rows
    new_image.crop!(width/2 - new_width/2, height/2 - new_height/2, new_width, new_height)
    new_image
  end

end
