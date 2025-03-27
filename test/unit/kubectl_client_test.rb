require_relative '../helper'
require 'mixlib/shellout'
require 'train-kubernetes/kubectl_client'

class TestKubectlClient < Minitest::Test
  def setup
    @pod = 'mock-pod'
    @namespace = 'mock-namespace'
    @container = 'mock-container'
    @kubectl_client = TrainPlugins::TrainKubernetes::KubectlClient.new(pod: @pod, namespace: @namespace, container: @container)
  end

  def test_initialize
    assert_equal @pod, @kubectl_client.pod
    assert_equal @namespace, @kubectl_client.namespace
    assert_equal @container, @kubectl_client.container
  end

  def test_execute_success
    mock_shell = mock('Mixlib::ShellOut')
    mock_shell.stubs(:run_command).returns(mock_shell)
    mock_shell.stubs(:stdout).returns("command output")
    mock_shell.stubs(:stderr).returns("")
    mock_shell.stubs(:exitstatus).returns(0)

    Mixlib::ShellOut.stubs(:new).returns(mock_shell)

    result = @kubectl_client.execute('ls')
    assert_equal "command output", result.stdout
    assert_equal "", result.stderr
    assert_equal 0, result.exit_status
  end

  def test_execute_failure
    mock_shell = mock('Mixlib::ShellOut')
    mock_shell.stubs(:run_command).returns(mock_shell)
    mock_shell.stubs(:stdout).returns("")
    mock_shell.stubs(:stderr).returns("Error executing command")
    mock_shell.stubs(:exitstatus).returns(1)

    Mixlib::ShellOut.stubs(:new).returns(mock_shell)

    result = @kubectl_client.execute('ls')
    assert_equal "", result.stdout
    assert_equal "Error executing command", result.stderr
    assert_equal 1, result.exit_status
  end

  def test_execute_pod_not_found
    mock_shell = mock('Mixlib::ShellOut')
    mock_shell.stubs(:run_command).returns(mock_shell)
    mock_shell.stubs(:stdout).returns("")
    mock_shell.stubs(:stderr).returns("Error from server (NotFound): pods \"#{@pod}\" not found")
    mock_shell.stubs(:exitstatus).returns(1)

    Mixlib::ShellOut.stubs(:new).returns(mock_shell)

    result = @kubectl_client.execute('ls')
    assert_match /Error from server \(NotFound\): pods \"#{@pod}\" not found/, result.stderr
    assert_equal 1, result.exit_status
  end

  def test_execute_with_no_kubectl
    Mixlib::ShellOut.stubs(:new).raises(Errno::ENOENT)

    result = @kubectl_client.execute('ls')
    assert_equal "", result.stdout
    assert_equal "", result.stderr
    assert_equal 1, result.exit_status
  end
end
