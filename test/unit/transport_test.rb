require_relative "../helper"
require "train-kubernetes/transport"
require "train-kubernetes/connection"

class TestTrainKubernetesTransport < Minitest::Test
  def setup
    @options = {
      kubeconfig: "/path/to/mock-kubeconfig",
      pod: "mock-pod",
      container: "mock-container",
      namespace: "mock-namespace",
      enable_audit_log: false,
      audit_log_location: nil,
      audit_log_app_name: "train",
      audit_log_size: nil,
      audit_log_frequency: 0,
    }
    @transport = TrainPlugins::TrainKubernetes::Transport.new(@options)
  end

  def test_initialize
    assert_equal @options[:kubeconfig], @transport.options[:kubeconfig]
    assert_equal @options[:pod], @transport.options[:pod]
    assert_equal @options[:container], @transport.options[:container]
    assert_equal @options[:namespace], @transport.options[:namespace]
  end

  def test_connection
    mock_connection = mock("TrainPlugins::TrainKubernetes::Connection")
    TrainPlugins::TrainKubernetes::Connection.expects(:new).with(@options).returns(mock_connection)

    assert_equal mock_connection, @transport.connection
  end

  def test_connection_caching
    mock_connection = mock("TrainPlugins::TrainKubernetes::Connection")
    TrainPlugins::TrainKubernetes::Connection.expects(:new).once.returns(mock_connection)

    connection1 = @transport.connection
    connection2 = @transport.connection

    assert_same connection1, connection2
  end
end
