require 'train-kubernetes'

RSpec.describe 'TrainKubernetes::File::LinuxPermissions' do
  let(:inspec) { double('inspec') }
  let(:pod) { 'test-pod' }
  let(:namespace) { 'test-namespace' }
  let(:container) { 'test-container' }

  subject { TrainKubernetes::File::LinuxPermissions.new(inspec, pod: pod, namespace: namespace, container: container) }

  it 'should set the pod' do
    expect(subject.pod).to eq(pod)
  end

  it 'should set the namespace' do
    expect(subject.namespace).to eq(namespace)
  end

  it 'should set the container' do
    expect(subject.container).to eq(container)
  end

  it 'should call the super constructor with inspec' do
    expect(TrainKubernetes::File::LinuxPermissions.superclass).to receive(:new).with(inspec)
    subject
  end
end