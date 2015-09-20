module SimpleSignature

  class Generator
    require 'openssl'
    
    attr_reader :token, :data

    def initialize key, timestamp = nil, &block
      @data = []
      @token = SimpleSignature.keystore.get(key)
      @timestamp = timestamp

      yield self if block_given?
    end

    def reset!
      @data.clear
      @timestamp = nil
      @signature = nil
    end

    def include_all data
      @data << [ data[:method].to_s.upcase, data[:path], query_string(data[:params]), data[:body] ]
    end

    def include_query params
      @data << query_string(params)
    end
    
    def timestamp
      @timestamp ||= Time.now.to_i
    end

    def signature
      if @token
        @signature ||= sign(@token.secret, payload)
      end
    end

    def auth_hash
      {
        SimpleSignature.key_param_name => @token.key, 
        SimpleSignature.signature_param_name => signature, 
        SimpleSignature.timestamp_param_name => timestamp
      }
    end

    def auth_params
      URI.encode_www_form(auth_hash)
    end
    
    def payload
      [@data.join, timestamp].join
    end
    
    
    private
    
    def sign secret, payload
      hmac.hexdigest(sha1, secret, payload)
    end

    def hmac
      OpenSSL::HMAC
    end 
  
    def sha1
      @sha1 ||= OpenSSL::Digest::SHA1.new
    end
    
    def query_string params
      Query.new(params).sort.to_s
    end
  end
end
