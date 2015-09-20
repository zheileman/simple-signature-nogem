require 'spec_helper'
require 'simple_signature'

describe SimpleSignature::Keystore do

  let(:keys) do
    {
      'microservice1' => {secret: 'Hs26CH1sSjTEnub38PJk8IKiHgcoxdPGVtX0geCyas9AFS6cvbu9GRHe81eocub'}, 
      'microservice2' => {secret: 'QJwgWfXgu45GZ866tHDMCWWPj7s0PdlcnlkzZaBCzE2aOomirlPuMB99PJePmzL'} 
    }
  end

  subject { SimpleSignature::Keystore.new(keys) }

  describe '#first' do
    it "should return the first found key if any" do
      expect(subject.first).to eq('microservice1')
    end
  end
  
  describe "#get" do
    it "should return a token if the key exists" do
      expect(subject.get('microservice1')).not_to be_nil
    end

    it "should return nil for a non existing key" do
      expect(subject.get('test')).to be_nil
    end
  end
end
