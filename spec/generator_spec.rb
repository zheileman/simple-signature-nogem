require 'spec_helper'
require 'simple_signature'

describe SimpleSignature::Generator do
  
  subject do
    SimpleSignature::Generator
  end

  let(:keystore) { SimpleSignature::Keystore.new({'service' => {'secret' => 'xxxxx'}}) }

  before :each do
    SimpleSignature.stub(keystore: keystore)
  end

  describe '.new' do
    let(:sign_data) { { method: 'get', path: '/test' } }
    
    it "should not fail for a non existing key" do
      expect(subject.new('test')).not_to be_nil
    end

    it "should accept a timestamp argument" do
      timestamp = Time.now.to_i - 10000
      expect(subject.new('service', timestamp).timestamp).to eq(timestamp)
    end

    it "should generate a timestamp if there is no argument" do
      expect(subject.new('service').timestamp).to eq(Time.now.to_i)
    end
    
    it "should accept a block with calls to #include_all" do
      expect(subject.new('service') do |g|
        g.include_all sign_data
      end).not_to be_nil
    end
    
    it "should allow to be instantiated without a block, and after that allow calls to #include" do
      signature1 = subject.new('service') do |g|
        g.include_all sign_data
      end
      
      signature2 = subject.new('service', signature1.timestamp)
      signature2.include_all sign_data
      expect(signature1.signature).to eq(signature2.signature) 
    end
    
    it "should accept calls to #include_query with a Hash and reorder it to convert into a query string" do
      params = {:x => 1, :a => 2}
      generator = subject.new('service')
      generator.include_query params
      expect(generator.data).to eq(["a=2&x=1"])
    end
    
    it "should accept calls to #include_query with a complex Hash and reorder it to convert into a query string" do
      params = {
        'session_user_uuid' => '92c0fe8c-21ae-4e81-aa74-6eeab53575a9',
        'folder[name]' => 'Test folder',
        'folder[group]' => true
      }
      generator = subject.new('service')
      generator.include_query params
      expect(generator.data).to eq(["folder%5Bgroup%5D=true&folder%5Bname%5D=Test+folder&session_user_uuid=92c0fe8c-21ae-4e81-aa74-6eeab53575a9"])
    end
    
    it "should accept calls to #include_query with a query string and reorder it" do
      params = "x=1&a=2"
      generator = subject.new('service')
      generator.include_query params
      expect(generator.data).to eq(["a=2&x=1"])
    end
  end

  describe "#signature" do
    it "should return a signature" do
      expect(subject.new('service').signature).not_to be_nil
    end
    
    it "should return nil for an unknown key" do
      expect(subject.new('test').signature).to be_nil
    end
  end

  describe "#auth_hash" do
    it "should return a hash with the signature information" do
      key = 'service'
      hash = subject.new(key).auth_hash
      expect(hash['sigkey']).to eq(key)
      expect(hash['timestamp']).not_to be_nil
      expect(hash['signature']).not_to be_nil
    end
  end
end
