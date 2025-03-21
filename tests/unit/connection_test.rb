require 'train-kubernetes'

RSpec.describe 'TrainKubernetes' do
  describe 'Connection' do
    let(:options) { { pod: 'test-pod', container: 'test-container', namespace: 'test-namespace' } }
    let(:connection) { TrainKubernetes::Connection.new(options) }

    it 'should connect to the Kubernetes API' do
      expect(connection.client).to be_a(K8s::Client)
    end

    it 'should have a valid URI' do
      expect(connection.uri).to eq('kubernetes://default')
    end

    it 'should parse the kubeconfig file' do
      expect(connection.client.config).to be_a(K8s::Config)
    end

    it 'should run a command via connection' do
      cmd = 'echo "Hello, World!"'
      expect_any_instance_of(KubectlClient).to receive(:execute).with(cmd)
      connection.run_command_via_connection(cmd)
    end

    it 'should create a file object via connection' do
      path = '/path/to/file.txt'
      file = connection.file_via_connection(path)
      expect(file).to be_a(TrainPlugins::TrainKubernetes::File::Linux)
      expect(file.path).to eq(path)
      expect(file.pod).to eq(options[:pod])
      expect(file.container).to eq(options[:container])
      expect(file.namespace).to eq(options[:namespace])
    end
  end
end