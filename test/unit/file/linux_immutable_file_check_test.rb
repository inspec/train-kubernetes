require_relative '../../helper'
require 'inspec/exceptions'
require 'train-kubernetes/file/linux_immutable_file_check'

class TestLinuxImmutableFileCheck < Minitest::Test
  def setup
    @inspec = mock('Inspec')
    @backend = mock('Backend')
    @file_path = '/mock/file'

    # Mock the file resource to ensure it behaves like Inspec's FileResource
    @file_resource = mock('FileResource')
    @file_resource.stubs(:path).returns(@file_path)

    @inspec.stubs(:backend).returns(@backend)
    @inspec.stubs(:file).with(@file_path).returns(@file_resource) # Ensure it returns a mock FileResource

    @options = { pod: 'mock-pod', container: 'mock-container', namespace: 'mock-namespace' }

    # Now we pass the mocked file resource instead of a string
    @file_check = TrainPlugins::TrainKubernetes::File::LinuxImmutableFileCheck.new(@inspec, @file_resource, **@options)
  end


  def test_find_utility_or_error_success
    @backend.expects(:run_command).with("sh -c 'type \"/usr/sbin/lsattr\"'", @options).returns(mock(exit_status: 0))
    assert_equal '/usr/sbin/lsattr', @file_check.send(:find_utility_or_error, 'lsattr')
  end

  def test_find_utility_or_error_failure
    mock_backend = mock('Backend')

    # Mock multiple responses for exit_status as it checks multiple locations
    mock_command_result = mock('CommandResult')
    mock_command_result.stubs(:exit_status).returns(1) # Command not found

    mock_backend.stubs(:run_command).returns(mock_command_result)
    @inspec.stubs(:backend).returns(mock_backend)

    assert_raises(Inspec::Exceptions::ResourceFailed) do
      @file_check.find_utility_or_error('nonexistent_utility')
    end
  end


  def test_is_immutable_success
    mock_command = mock(exit_status: 0, stdout: '----i---------e----- /mock/file')
    @file_check.stubs(:find_utility_or_error).returns('/usr/sbin/lsattr')
    @backend.expects(:run_command).with('/usr/sbin/lsattr /mock/file', @options).returns(mock_command)
    assert @file_check.is_immutable?
  end

  def test_is_immutable_failure
    mock_command = mock(exit_status: 1, stderr: 'Error executing lsattr')
    @file_check.stubs(:find_utility_or_error).returns('/usr/sbin/lsattr')
    @backend.expects(:run_command).with('/usr/sbin/lsattr /mock/file', @options).returns(mock_command)
    assert_raises(Inspec::Exceptions::ResourceFailed) { @file_check.is_immutable? }
  end
end
