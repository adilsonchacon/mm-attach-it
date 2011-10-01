require 'wand'

class AttachmentOptions

  attr_accessor :styles, :assigned_file, :object_id, :name

  def initialize(model = nil, name = nil, options = {})
    @model = model
    @class_name = model.class.name.downcase
    @object_id = model.id.to_s

    @name = name
    @attachment = name.to_s.downcase.pluralize

    @url = set_url(options[:url], options[:default_url])
    @path = set_path(options[:path])
    @styles = set_styles(options[:styles])
    @storage = set_storage(options[:storage])

    if !@model.send("#{@name.to_s}_file_name").nil?
      @filename = @model.send("#{@name.to_s}_file_name")
      @extension = set_extension(@model.send("#{@name.to_s}_file_name"))
    end

    @queued_for_delete = set_queued_for_delete

    @errors = Hash.new
  end

  def assign(file = nil)
    @errors = {}

    @filename = file_name(file)
    @extension = set_extension(@filename)
    file = file.tempfile if file.respond_to?(:tempfile)

    @model.send("#{@name.to_s}_file_name=", @filename)
    @model.send("#{@name.to_s}_file_size=", File.size(file))
    @model.send("#{@name.to_s}_content_type=", Wand.wave(file.path))
    @model.send("#{@name.to_s}_updated_at=", Time.now)

    add_error('Could not resize file') unless file_is_resizale?
  end

  def url(style_name = 'original')
    return nil unless @storage.is_a?(Filesystem)
    interpolate(@url, style_name)
  end

  def path(style_name = 'original')
    return nil unless @storage.is_a?(Filesystem)
    interpolate(@path, style_name)
  end

  def save
    unless @assigned_file.nil?
      @storage.flush_delete(@queued_for_delete)
      @storage.flush_write(self)
      @queued_for_delete = set_queued_for_delete
    end
  end

  def delete
    @storage.flush_delete(@queued_for_delete)
  end

  def add_error(description = nil)
    (@errors[:processing] ||= []) << description
  end

  def flush_errors
    @errors.each do |error, message|
      [message].flatten.each { |m| @model.errors.add(@name, m) }
    end
  end

  def file_name(file = nil)
    @assigned_file ||= file
    @assigned_file.respond_to?(:original_filename) ? @assigned_file.original_filename : File.basename(@assigned_file.path)
  end

  def get_from_gridfs(style = 'original')
    if @storage.is_a?(Gridfs)
      @storage.read("#{@object_id}_#{@name}_#{style}")
    else
      nil
    end
  end

  def base64(style = 'original')
    begin
      bytes = nil

      if @storage.is_a?(Gridfs)
        bytes = get_from_gridfs(style).read
      elsif @storage.is_a?(Filesystem)
        bytes = File.open(path(style), 'rb').read
      end

      'data:' + @model.send("#{@name.to_s}_content_type") + ';base64,' + Base64.encode64(bytes)
    rescue Exception => exception
      nil
    end
  end

  private
  def interpolate(source = nil, style_name = nil)
    result = source.gsub(/\:rails_root/, Rails.root.to_s)
    result.gsub!(/\:environment/, Rails.env)
    result.gsub!(/\:filename/, @filename.nil? ? '' : @filename)
    result.gsub!(/\:extension/, @extension.nil? ? '' : @extension)
    result.gsub!(/\:style/, style_name.to_s)
    result.gsub!(/\:id/, @object_id)
    result.gsub!(/\:class/, @class_name)
    result.gsub!(/\:attachment/, @attachment)
    result.gsub!(/(\/){2,}/, '/')
    while result.match(/:model\.([A-Za-z\_]+)/)
      result.sub!(/:model\.[A-Za-z\_]+/, @model.send($1))
    end
    result
  end

  def set_storage(storage_option = nil)
    storage_option = 'filesystem' if storage_option.nil?
    (storage_option == 'filesystem') ? Filesystem.new : Gridfs.new
  end

  def set_styles(style_option = nil)
    style_option.nil? ? {} : style_option
  end

  def set_url(url_option = nil, default_url = nil)
    @default_url = default_url
    if url_option.nil?
      (@default_url.nil? ? '/system/:attachment/:id/:style/:filename' : @default_url)
    else
      url_option
    end
  end

  def set_path(path_option = nil)
    path_option.nil? ? ':rails_root/public/system/:attachment/:id/:style/:filename' : path_option
  end

  def set_extension(source_path_option = nil)
    source_path_option.nil? ? nil : File.extname(source_path_option)
  end

  def set_queued_for_delete
    if @storage.is_a?(Filesystem)
      [@styles.keys, :original].flatten.map do |style_name|
        path(style_name) if File.exists?(path(style_name))
      end.compact
    else
      [@styles.keys, :original].flatten.map do |style_name|
        "#{@object_id}_#{@name}_#{style_name}"
      end.compact
    end
  end

  def file_is_resizale?
    if @styles.keys.size > 0
      result = ''
      IO.popen("identify -format %wx%h #{@assigned_file.path} 2>&1") do |o|
        @pid = o.pid
        while line = o.gets do
          result = result + line.to_s
        end
      end

      !result.match(/^\d+x\d+$/).nil?
    else
      true
    end
  end
end
