require 'train-kubernetes'

RSpec.describe 'TrainKubernetes' do
  describe 'KubectlClient' do
    let(:pod) { 'my-pod' }
    let(:namespace) { 'my-namespace' }
    let(:container) { 'my-container' }
    let(:client) { TrainKubernetes::KubectlClient.new(pod: pod, namespace: namespace, container: container) }

    describe '#initialize' do
      it 'sets the pod, container, and namespace' do
        expect(client.pod).to eq(pod)
        expect(client.container).to eq(container)
        expect(client.namespace).to eq(namespace)
      end

      it 'sets the default namespace if not provided' do
        client = TrainKubernetes::KubectlClient.new(pod: pod)
        expect(client.namespace).to eq(TrainKubernetes::KubectlClient::DEFAULT_NAMESPACE)
      end
    end

    describe '#execute' do
      it 'executes the command and returns the command result' do
        command = 'echo "Hello, World!"'
        shell_out = double('shell_out')
        expect(Mixlib::ShellOut).to receive(:new).and_return(shell_out)
        expect(shell_out).to receive(:run_command)

        result = double('command_result')
        expect(Train::Extras::CommandResult).to receive(:new).and_return(result)

        expect(client.execute(command)).to eq(result)
      end

      it 'returns an empty command result if the command fails' do
        command = 'invalid-command'
        expect(Mixlib::ShellOut).to receive(:new).and_raise(Errno::ENOENT)

        result = double('command_result')
        expect(Train::Extras::CommandResult).to receive(:new).and_return(result)

        expect(client.execute(command)).to eq(result)
      end
    end
  end
end