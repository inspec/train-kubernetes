require 'train-kubernetes'

RSpec.describe 'TrainKubernetes' do
  describe 'components' do
    it 'should require the platform file' do
      expect { require 'train-kubernetes/platform' }.not_to raise_error
    end
  end

  describe 'Platform' do
    include TrainKubernetes::Platform

    it 'should define the platform method' do
      expect(self).to respond_to(:platform)
    end

    it 'should set the correct platform name and family' do
      expect(Train::Platforms).to receive(:name).with('k8s').and_return(Train::Platforms)
      expect(Train::Platforms).to receive(:in_family).with('cloud').and_return(Train::Platforms)
      platform
    end

    it 'should force the correct platform with the version' do
      expect(self).to receive(:force_platform!).with('k8s', release: TrainPlugins::TrainKubernetes::VERSION)
      platform
    end
  end
end