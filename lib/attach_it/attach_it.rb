module AttachIt

  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def has_attachment(name, options = {})
      options = options.symbolize_keys
      name = name.to_sym

      after_save     :save_attachments
      before_destroy :destroy_attachments

      key :"#{name}_file_name", String
      key :"#{name}_file_size", Integer
      key :"#{name}_content_type", String
      key :"#{name}_updated_at", Date

      define_method("#{name}=") do |file|
        information_for(name, options).assign(file)
      end

      define_method("#{name}") do
        information_for(name, options)
      end
  

      validates_each(name) do |record, attr, value|
        record.information_for(name, options).send(:flush_errors)
      end

    end

    def validates_attachment_size(name = nil, options = {})
      min     = options[:greater_than] || (options[:in] && options[:in].first) || 0
      max     = options[:less_than]    || (options[:in] && options[:in].last)  || (1.0/0)
      range   = (min..max)
      message = options[:message] || "file size must be between :min and :max bytes"
      message = message.gsub(/:min/, min.to_s).gsub(/:max/, max.to_s)

      validates_inclusion_of :"#{name}_file_size",
                             :in        => range,
                             :message   => message,
                             :allow_nil => true
    end

    def validates_attachment_presence(name = nil, options = {})
      message = options[:message] || "must be set"
      validates_presence_of :"#{name}_file_name",
                            :message   => message,
                            :if        => options[:if]
    end

    def validates_attachment_content_type(name = nil, options = {})
      validation_options = options.dup
      allowed_types = [validation_options[:content_type]].flatten
      message = options[:message] || "is not one of #{allowed_types.join(", ")}"

      validates_inclusion_of :"#{name}_content_type",
                             :in        => allowed_types,
                             :message   => message,
                             :allow_nil => true
    end
  end

  module InstanceMethods
    def information_for(name = nil, options = nil)
      @attachment_options ||= {}
      @attachment_options[name] ||= AttachmentOptions.new(self, name, options)
    end

    def save_attachments
      @attachment_options.keys.each do |name|
        @attachment_options[name].save
      end
    end

    def destroy_attachments
      unless @attachment_options.nil?
        @attachment_options.keys.each do |name|
          @attachment_options[name].delete
        end
      end
    end

  end
end
