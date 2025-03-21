require 'train-kubernetes'

RSpec.describe 'TrainKubernetes::File::Linux' do
  let(:backend) { double('backend') }
  let(:path) { '/path/to/file' }
  let(:follow_symlink) { true }
  let(:pod) { 'my-pod' }
  let(:container) { 'my-container' }
  let(:namespace) { 'my-namespace' }

  it 'should initialize with default options' do
    file = TrainKubernetes::File::Linux.new(backend, path, follow_symlink, pod: pod)
    expect(file.instance_variable_get(:@backend)).to eq(backend)
    expect(file.instance_variable_get(:@path)).to eq(path)
    expect(file.instance_variable_get(:@follow_symlink)).to eq(follow_symlink)
    expect(file.instance_variable_get(:@pod)).to eq(pod)
    expect(file.instance_variable_get(:@container)).to be_nil
    expect(file.instance_variable_get(:@namespace)).to be_nil
  end

  it 'should initialize with custom options' do
    file = TrainKubernetes::File::Linux.new(backend, path, follow_symlink, pod: pod, container: container, namespace: namespace)
    expect(file.instance_variable_get(:@backend)).to eq(backend)
    expect(file.instance_variable_get(:@path)).to eq(path)
    expect(file.instance_variable_get(:@follow_symlink)).to eq(follow_symlink)
    expect(file.instance_variable_get(:@pod)).to eq(pod)
    expect(file.instance_variable_get(:@container)).to eq(container)
    expect(file.instance_variable_get(:@namespace)).to eq(namespace)
  end
end