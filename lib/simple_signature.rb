module SimpleSignature
  Dir[File.dirname(__FILE__) + "/simple_signature/*.rb"].each { |file| require file }
  
  class << self
    attr_writer :keystore, :expiry_time, :key_param_name, :signature_param_name, :timestamp_param_name
    attr_writer :logger

    def configure
      if block_given?
        yield self
        true
      end
    end

    def init_keystore keys
      @keystore = SimpleSignature::Keystore.new(keys)
    end

    def keystore
      @keystore || init_keystore({})
    end
    def expiry_time
      @expiry_time ||= 900
    end
    def key_param_name
      @key_param_name ||= 'sigkey'
    end
    def signature_param_name
      @signature_param_name ||= 'signature'
    end
    def timestamp_param_name
      @timestamp_param_name ||= 'timestamp'
    end
    def logger
      @logger
    end
  end
end
