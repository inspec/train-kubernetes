require_relative '../helper'
require 'train-kubernetes/platform'
require 'train-kubernetes/version'


module TrainPlugins
  module TrainKubernetes
    class TestClass
      include Platform
    end
  end
end

class TestTrainKubernetesPlatform < Minitest::Test
  def setup
    @test_instance = TrainPlugins::TrainKubernetes::TestClass.new
  end

  def test_platform
    platform_mock = mock('platform')
    platform_mock.expects(:in_family).with('cloud').returns(true)

    Train::Platforms.expects(:name).with('k8s').returns(platform_mock)
    @test_instance.expects(:force_platform!).with('k8s', release: TrainPlugins::TrainKubernetes::VERSION).returns(true)

    assert @test_instance.platform
  end
end
