class Filesystem < Storage

  def flush_write(image_options = nil)
    image_options.styles.each do |style_name, style_value|
      begin        
        FileUtils.mkdir_p(File.dirname(image_options.path(style_name)))
        transform(style_value, image_options.assigned_file.path).write(image_options.path(style_name)) 
        FileUtils.chmod(0644, image_options.path(style_name))
      rescue Exception => exception
        image_options.add_error(exception.to_s)
      end
    end

    unless image_options.styles.has_key?(:original)
      begin
        FileUtils.mkdir_p(File.dirname(image_options.path(:original)))
        FileUtils.cp(image_options.assigned_file.path, image_options.path(:original)) 
      rescue Exception => exception
        image_options.add_error(exception.to_s)
      end
    end
  end

  def flush_delete(queued_for_delete = nil)
    queued_for_delete.each do |file|
      FileUtils.rm(file) if File.exist?(file)
    end
  end

end
