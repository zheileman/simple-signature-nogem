module SimpleSignature

  class Query
    require 'cgi'

    attr_reader :params

    def initialize query
      @params = query.is_a?(Hash) ? query : CGI.parse(query.to_s)
    end

    def sort
      @params = Hash[@params.sort]
      self
    end

    def except *keys
      keys.each { |k| @params.delete(k) }
      self
    end

    def to_s
      URI.encode_www_form(@params)
    end
  end

end
