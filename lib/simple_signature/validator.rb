module SimpleSignature

  class Validator
    attr_reader :generator, :timestamp, :key, :error
    attr_reader :logger

    def initialize key, signature, timestamp, options = {}, &block
      @key = key
      @signature = signature
      @timestamp = timestamp
      @generator = Generator.new(key, timestamp, &block)
      
      @expiry_time = options[:expiry_time] || SimpleSignature.expiry_time
      @logger = options.fetch(:logger, SimpleSignature.logger)
    end

    def expired?
      Time.now > Time.at(@timestamp.to_i + @expiry_time) rescue true
    end
    
    def corrupt?
      @signature.nil? || @signature == "" || @timestamp.nil? || @timestamp == "" || @key.nil? || @key == ""
    end
    
    def unknown_token?
      @generator.token.nil?
    end
    
    
    def success?
      if corrupt?
        @error = ValidatorError.corrupt
      elsif unknown_token?
        @error = ValidatorError.unknown_token(@key)
      elsif expired?
        @error = ValidatorError.expired
      elsif @generator.signature != @signature
        @error = ValidatorError.invalid
      else
        @error = nil
      end
      
      if @error
        log :error, "%s Signature: %s. Token: %s. Timestamp: %s." % [@error, @signature, @key, @timestamp]
        log :error, "Using payload '%s' with secret '%s***' from token '%s' generates signature '%s'" % 
          [@generator.payload, @generator.token.secret[0..5], @generator.token.key, @generator.signature] if @error == ValidatorError.invalid
      end
      
      @error.nil?
    end
    
    
    private
    
    def log level, msg
      (@logger.is_a?(Proc) ? @logger.call : @logger).send(level, "[#{self.class.name}] #{msg}") if @logger
    end
  end

end
