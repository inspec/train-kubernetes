require_relative "../helper"
require "train-kubernetes/connection"

# Mock KubectlClient if it's not required from another file
class KubectlClient
  def initialize(*); end

  def execute(_cmd)
    Train::Extras::CommandResult.new("file1\nfile2", "", 0)
  end
end

class TestTrainKubernetesConnection < Minitest::Test
  def setup
    @options = {
      pod: "hello-minikube-ffcbb5874-7znbm",
      container: "test-container",
      namespace: "default",
      kubeconfig: "test/fixtures/kubeconfig",
    }
    @mock_client = mock("K8s::Client")
    @mock_client.stubs(:apis).returns(true)
    @mock_transport = mock("transport")
    @mock_transport.stubs(:server).returns("https://test-server")
    @mock_client.stubs(:transport).returns(@mock_transport)
    K8s::Client.stubs(:config).returns(@mock_client)

    @connection = TrainPlugins::TrainKubernetes::Connection.new(@options)
  end

  def test_initialize
    assert_equal "hello-minikube-ffcbb5874-7znbm", @connection.send(:pod)
    assert_equal "test-container", @connection.send(:container)
    assert_equal "default", @connection.send(:namespace)
    assert_equal @mock_client, @connection.client
  end

  def test_connect
    @mock_client.expects(:apis).returns(true)
    @connection.connect
  end

  def test_uri
    assert_equal "kubernetes://test-server", @connection.uri
  end

  def test_unique_identifier
    assert_equal "test-server", @connection.unique_identifier
  end

  def test_parse_kubeconfig
    assert_equal @mock_client, @connection.client
  end

  def test_parse_kubeconfig_missing_option
    options = {
      pod: "hello-minikube-ffcbb5874-7znbm",
      container: "test-container",
      namespace: "default",
    }

    error = assert_raises(Train::UserError) do
      TrainPlugins::TrainKubernetes::Connection.new(options)
    end

    assert_match(/No kubeconfig file specified/, error.message)
  end

  def test_parse_kubeconfig_file_not_found
    options = {
      pod: "hello-minikube-ffcbb5874-7znbm",
      container: "test-container",
      namespace: "default",
      kubeconfig: "/nonexistent/path/to/kubeconfig",
    }

    error = assert_raises(Train::UserError) do
      TrainPlugins::TrainKubernetes::Connection.new(options)
    end

    assert_match(/Kubeconfig file not found/, error.message)
    assert_match(%r{/nonexistent/path/to/kubeconfig}, error.message)
  end

  def test_parse_kubeconfig_invalid_yaml
    require "tempfile"

    invalid_yaml = Tempfile.new(["invalid_kubeconfig", ".yaml"])
    invalid_yaml.write("invalid: yaml: content: ::::")
    invalid_yaml.close

    options = {
      pod: "hello-minikube-ffcbb5874-7znbm",
      container: "test-container",
      namespace: "default",
      kubeconfig: invalid_yaml.path,
    }

    # Mock K8s::Config to raise a Psych error
    K8s::Config.stubs(:load_file).raises(Psych::SyntaxError.new("test file", 1, 1, 0, "mapping values are not allowed in this context", "Object"))

    error = assert_raises(Train::UserError) do
      TrainPlugins::TrainKubernetes::Connection.new(options)
    end

    assert_match(/Invalid YAML syntax in kubeconfig file/, error.message)
  ensure
    invalid_yaml&.unlink
    K8s::Config.unstub(:load_file)
  end

  def test_parse_kubeconfig_invalid_kubernetes_config
    require "tempfile"

    # Create a valid YAML file but with invalid kubeconfig content
    invalid_config = Tempfile.new(["invalid_k8s_config", ".yaml"])
    invalid_config.write("some: valid\nyaml: content\nbut: not_kubeconfig")
    invalid_config.close

    options = {
      pod: "hello-minikube-ffcbb5874-7znbm",
      container: "test-container",
      namespace: "default",
      kubeconfig: invalid_config.path,
    }

    # Mock K8s::Config to raise a K8s::Error
    K8s::Config.stubs(:load_file).raises(K8s::Error.new("Missing required field: clusters"))

    error = assert_raises(Train::UserError) do
      TrainPlugins::TrainKubernetes::Connection.new(options)
    end

    assert_match(/Invalid kubeconfig file/, error.message)
    assert_match(/Missing required field/, error.message)
  ensure
    invalid_config&.unlink
    K8s::Config.unstub(:load_file)
  end
end
