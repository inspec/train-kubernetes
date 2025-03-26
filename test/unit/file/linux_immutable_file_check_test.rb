require 'train-kubernetes'

RSpec.describe 'TrainKubernetes' do
  describe 'components' do
    it 'should require the linux_immutable_file_check file' do
      expect { require 'train-kubernetes/file/linux_immutable_file_check' }.not_to raise_error
    end
  end
end