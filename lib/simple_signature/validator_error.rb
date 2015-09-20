module SimpleSignature
  
  class ValidatorError < Struct.new(:code, :message)
    def self.expired
      new('signature_expired', 'Signature has expired.')
    end
    def self.invalid
      new('signature_invalid', 'Signature is not valid.')
    end
    def self.corrupt
      new('signature_corrupt', 'Signature is missing mandatory attributes.')
    end
    def self.unknown_token key
      new('signature_unknown_token', "Signature token '#{key}' was not found in keystore.")
    end
    
    def to_s
      message
    end
  end
  
end
