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

end
