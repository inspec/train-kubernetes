require_relative '../helper'
require 'train-kubernetes/connection'

# Mock KubectlClient if it's not required from another file
class KubectlClient
  def initialize(*); end

  def execute(_cmd)
    Train::Extras::CommandResult.new("file1\nfile2", '', 0)
  end
end

class TestTrainKubernetesConnection < Minitest::Test
  def setup
    @options = {
      pod: 'hello-minikube-ffcbb5874-7znbm',
      container: 'test-container',
      namespace: 'default',
      kubeconfig: 'test/fixtures/kubeconfig'
    }
    @mock_client = mock('K8s::Client')
    @mock_client.stubs(:apis).returns(true)
    @mock_transport = mock('transport')
    @mock_transport.stubs(:server).returns('https://test-server')
    @mock_client.stubs(:transport).returns(@mock_transport)
    K8s::Client.stubs(:config).returns(@mock_client)

    @connection = TrainPlugins::TrainKubernetes::Connection.new(@options)
  end

  def test_initialize
    assert_equal 'hello-minikube-ffcbb5874-7znbm', @connection.send(:pod)
    assert_equal 'test-container', @connection.send(:container)
    assert_equal 'default', @connection.send(:namespace)
    assert_equal @mock_client, @connection.client
  end

  def test_connect
    @mock_client.expects(:apis).returns(true)
    @connection.connect
  end

  def test_uri
    assert_equal 'kubernetes://test-server', @connection.uri
  end

  def test_unique_identifier
    assert_equal 'test-server', @connection.unique_identifier
  end

  def test_parse_kubeconfig
    assert_equal @mock_client, @connection.client
  end

  def test_parse_kubeconfig_missing_option
    err = assert_raises(Train::UserError) do
      TrainPlugins::TrainKubernetes::Connection.new(@options.merge(kubeconfig: nil))
    end
    assert_includes err.message, 'No kubeconfig file specified'
  end

  def test_parse_kubeconfig_file_not_found
    err = assert_raises(Train::UserError) do
      TrainPlugins::TrainKubernetes::Connection.new(@options.merge(kubeconfig: '/nonexistent/path/config'))
    end
    assert_includes err.message, 'Kubeconfig file not found'
    assert_includes err.message, '/nonexistent/path/config'
  end

  def test_parse_kubeconfig_invalid_yaml
    # Create a temporary file with invalid YAML
    require 'tempfile'
    Tempfile.create(['invalid', '.yaml']) do |file|
      file.write('invalid: yaml: syntax: :')
      file.flush

      err = assert_raises(Train::UserError) do
        TrainPlugins::TrainKubernetes::Connection.new(@options.merge(kubeconfig: file.path))
      end
      assert_includes err.message, 'Invalid YAML syntax'
    end
  end

  def test_parse_kubeconfig_invalid_kubernetes_config
    # Create a temporary file with valid YAML but invalid K8s config
    require 'tempfile'
    Tempfile.create(['invalid_k8s', '.yaml']) do |file|
      file.write("apiVersion: v1\nkind: InvalidKind\n")
      file.flush

      K8s::Config.stubs(:load_file).raises(K8s::Error.new('Invalid Kubernetes configuration'))

      err = assert_raises(Train::UserError) do
        TrainPlugins::TrainKubernetes::Connection.new(@options.merge(kubeconfig: file.path))
      end
      assert_includes err.message, 'Invalid kubeconfig file'
    end
  end
end
