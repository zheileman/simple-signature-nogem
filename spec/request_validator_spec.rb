require 'spec_helper'
require 'simple_signature'

describe SimpleSignature::RequestValidator do
  
  subject do
    SimpleSignature::RequestValidator
  end

  let(:keystore) { SimpleSignature::Keystore.new({'service' => {'secret' => 'xxxxx'}}) }
  let(:logger) { double('logger', error: true) }


  before :each do
    SimpleSignature.stub(keystore: keystore)
  end
  
  describe 'validate signatures' do
    let(:generator) {
      SimpleSignature::Generator.new('service') do |g|
        g.include_all method: request.request_method, path: request.path, params: request.query_string, body: request.body.read
      end
    }

    let(:request) {
      double('request', 
        request_method: 'POST', 
        path: '/api/v1.3/accounts.json', 
        query_string: 'p1=v1&p2=v2', 
        body: double(read: 'test=xxx', rewind: true))
    }
    
    it "should validate a proper signature from a request with query params" do
      allow(request).to receive(:params).and_return(generator.auth_hash)
      allow(request).to receive(:query_string).and_return(['p1=v1', generator.auth_params, 'p2=v2'].join('&'))

      validator = subject.new(request)

      expect(validator.logger).to be_nil
      expect(logger).to_not receive(:error)
      
      expect(validator.success?).to be_true
      expect(validator.error).to be_nil
    end
    
    it "should allow to provide a custom logger to output debug" do
      allow(request).to receive(:params).and_return(generator.auth_hash)
      allow(request).to receive(:query_string).and_return(['p1=v1', generator.auth_params, 'p2=v2'].join('&'))

      validator = subject.new(request, :logger => logger)
      expect(validator.logger).to eq(logger)
      
      expect(validator.success?).to be_true
      expect(validator.error).to be_nil
    end
        
    it "should fail and log the error in the custom logger if signature is wrong" do
      allow(request).to receive(:params).and_return(generator.auth_hash)
      allow(request).to receive(:query_string).and_return(['p1=v1', generator.auth_params, 'p2=v2'].join('&'))
      
      validator = subject.new(request, :logger => logger)
      allow(validator.generator).to receive(:signature).and_return('xxx')

      expect(validator.logger).to eq(logger)
      expect(logger).to receive(:error)
      
      expect(validator.success?).to be_false
      expect(validator.error).to_not be_nil
    end
    
    it "should fail and log the error in the custom logger (lambda) if signature is wrong" do
      allow(request).to receive(:params).and_return(generator.auth_hash)
      allow(request).to receive(:query_string).and_return(['p1=v1', generator.auth_params, 'p2=v2'].join('&'))
      
      validator = subject.new(request, :logger => ->{ logger })
      allow(validator.generator).to receive(:signature).and_return('xxx')

      expect(logger).to receive(:error)
      
      expect(validator.success?).to be_false
      expect(validator.error).to_not be_nil
    end
  end
  
end
