require_relative '../simple_signature/validator'

module SimpleSignature

  class RequestValidator < SimpleSignature::Validator
    attr_reader :request, :options

    def initialize request, options = {}
      @request = request
      @options = options

      super(key, signature, timestamp, options) do |generator|
        generator.include_all method: method, path: path, params: query_string, body: body
      end
    end

    def key
      @request.params[SimpleSignature.key_param_name]
    end
    def signature
      @request.params[SimpleSignature.signature_param_name]
    end
    def timestamp
      @request.params[SimpleSignature.timestamp_param_name]
    end
    def method
      @request.request_method.upcase
    end
    def path
      @request.path
    end
    
    def body
      if @options.key?(:body)
        Query.new(@options[:body]).sort.to_s
      else
        [@request.body.read, @request.body.rewind][0]
      end
    end
    
    def query_string
      if @options.key?(:params)
        Query.new(@options[:params]).sort.to_s
      else
        Query.new(@request.query_string).sort.except(
          SimpleSignature.key_param_name, SimpleSignature.signature_param_name, SimpleSignature.timestamp_param_name).to_s
      end
    end
  end

end
