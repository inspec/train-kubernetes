require 'train-kubernetes'

RSpec.describe 'TrainKubernetes' do
  describe 'entry point' do
    it 'should setup the load path' do
      expect($LOAD_PATH).to include(File.dirname(__FILE__))
    end

    it 'should load the gem version' do
      expect(TrainKubernetes::VERSION).not_to be_nil
    end
  end

  describe 'components' do
    it 'should require the transport file' do
      expect { require 'train-kubernetes/transport' }.not_to raise_error
    end

    it 'should require the platform file' do
      expect { require 'train-kubernetes/platform' }.not_to raise_error
    end

    it 'should require the linux file' do
      expect { require 'train-kubernetes/file/linux' }.not_to raise_error
    end
  end
end