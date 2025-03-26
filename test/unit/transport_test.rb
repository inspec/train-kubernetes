require 'train-kubernetes'

RSpec.describe 'TrainKubernetes' do
  describe 'components' do
    describe 'Transport' do
      it 'should create a connection with default options' do
        transport = TrainKubernetes::Transport.new
        connection = transport.connection
        expect(connection).to be_a(TrainPlugins::TrainKubernetes::Connection)
        expect(connection.options).to eq(transport.options)
      end

      it 'should create a connection with custom options' do
        transport = TrainKubernetes::Transport.new(kubeconfig: '/path/to/kubeconfig', pod: 'my-pod', container: 'my-container', namespace: 'my-namespace')
        connection = transport.connection
        expect(connection).to be_a(TrainPlugins::TrainKubernetes::Connection)
        expect(connection.options).to eq(transport.options)
      end
    end
  end
end