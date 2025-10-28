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

  # Test for missing kubeconfig option
  def test_parse_kubeconfig_missing_option
    options = {
      pod: "test-pod",
      container: "test-container",
      namespace: "default",
    }

    error = assert_raises(Train::UserError) do
      TrainPlugins::TrainKubernetes::Connection.new(options)
    end

    assert_match(/No kubeconfig file specified/, error.message)
    assert_match(/Please provide a kubeconfig path/, error.message)
  end

  # Test for kubeconfig file not found
  def test_parse_kubeconfig_file_not_found
    options = {
      pod: "test-pod",
      container: "test-container",
      namespace: "default",
      kubeconfig: "/nonexistent/path/to/kubeconfig",
    }

    error = assert_raises(Train::UserError) do
      TrainPlugins::TrainKubernetes::Connection.new(options)
    end

    assert_match(/Kubeconfig file not found/, error.message)
    assert_match(%r{/nonexistent/path/to/kubeconfig}, error.message)
    assert_match(/Please verify the path/, error.message)
  end

  # Test for invalid YAML syntax in kubeconfig
  def test_parse_kubeconfig_invalid_yaml
    invalid_kubeconfig_path = "test/fixtures/invalid_kubeconfig.yaml"
    
    # Create a temporary invalid YAML file
    File.write(invalid_kubeconfig_path, "invalid: yaml: syntax: :::::")

    options = {
      pod: "test-pod",
      container: "test-container",
      namespace: "default",
      kubeconfig: invalid_kubeconfig_path,
    }

    error = assert_raises(Train::UserError) do
      TrainPlugins::TrainKubernetes::Connection.new(options)
    end

    assert_match(/Invalid YAML syntax in kubeconfig file/, error.message)
  ensure
    # Clean up the temporary file
    File.delete(invalid_kubeconfig_path) if File.exist?(invalid_kubeconfig_path)
  end

  # Test for invalid Kubernetes configuration structure
  def test_parse_kubeconfig_invalid_k8s_config
    invalid_k8s_config_path = "test/fixtures/invalid_k8s_config.yaml"
    
    # Create a valid YAML but invalid K8s config
    File.write(invalid_k8s_config_path, "just_a_string: not_a_valid_k8s_config")

    options = {
      pod: "test-pod",
      container: "test-container",
      namespace: "default",
      kubeconfig: invalid_k8s_config_path,
    }

    # Mock K8s::Config to raise an error
    K8s::Config.stubs(:load_file).raises(K8s::Error, "Invalid configuration structure")

    error = assert_raises(Train::UserError) do
      TrainPlugins::TrainKubernetes::Connection.new(options)
    end

    assert_match(/Invalid kubeconfig file/, error.message)
  ensure
    # Clean up the temporary file
    File.delete(invalid_k8s_config_path) if File.exist?(invalid_k8s_config_path)
  end

end
