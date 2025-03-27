
require "base64"
require_relative "../../helper"
require "train-kubernetes/file/linux"

class TestLinuxFile < Minitest::Test
  def setup
    @backend = mock("Backend")
    @mock_command = mock("CommandResult")

    @linux_file = TrainPlugins::TrainKubernetes::File::Linux.new(
      @backend,
      "/mock/path",
      pod: "mock-pod",
      namespace: "mock-namespace",
      container: "mock-container",
    )
  end

  def test_content_returns_expected_output
    @mock_command.stubs(:stdout).returns("file content\n")
    @backend.expects(:run_command)
      .with("cat /mock/path || echo -n", { pod: "mock-pod", namespace: "mock-namespace", container: "mock-container" })
      .returns(@mock_command)

    assert_equal "file content\n", @linux_file.content
  end

  def test_content_handles_empty_output
    @mock_command.stubs(:stdout).returns("")
    @mock_command.stubs(:exit_status).returns(0)
    @backend.stubs(:run_command).returns(@mock_command)

    assert_nil @linux_file.content
  end

  def test_content_assignment_encodes_and_writes
    @backend.expects(:run_command)
      .with("base64 --help", { pod: "mock-pod", namespace: "mock-namespace", container: "mock-container" })
      .returns(@mock_command)

    @mock_command.stubs(:exit_status).returns(0)

    new_content = "New file content"
    encoded_content = Base64.strict_encode64(new_content)

    @backend.expects(:run_command)
      .with("echo '#{encoded_content}' | base64 --decode > /mock/path", { pod: "mock-pod", namespace: "mock-namespace", container: "mock-container" })

    @linux_file.content = new_content
  end

  def test_exist_returns_true_when_file_exists
    @mock_command.stubs(:exit_status).returns(0)
    @backend.stubs(:run_command).returns(@mock_command)

    assert @linux_file.exist?
  end

  def test_exist_returns_false_when_file_does_not_exist
    @mock_command.stubs(:exit_status).returns(1)
    @backend.stubs(:run_command).returns(@mock_command)

    refute @linux_file.exist?
  end

  def test_mounted_checks_if_file_is_mounted
    @mock_command.stubs(:stdout).returns("mock-mount-data")
    @backend.expects(:run_command)
      .with("mount | grep -- ' on /mock/path '", { pod: "mock-pod", namespace: "mock-namespace", container: "mock-container" })
      .returns(@mock_command)

    assert_equal "mock-mount-data", @linux_file.mounted.stdout
  end

  def test_path_follows_symlink
    @linux_file.stubs(:symlink?).returns(true)
    @linux_file.stubs(:read_target_path).returns("/mock/target")

    assert_equal "/mock/target", @linux_file.path
  end

  def test_path_does_not_follow_symlink
    @linux_file.stubs(:symlink?).returns(false)

    assert_equal "/mock/path", @linux_file.path
  end
end
