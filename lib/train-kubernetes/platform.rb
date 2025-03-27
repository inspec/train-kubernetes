module TrainPlugins
  module TrainKubernetes
    module Platform
      def platform
        Train::Platforms.name("k8s").in_family("cloud")
        force_platform!("k8s", release: TrainPlugins::TrainKubernetes::VERSION)
      end
    end
  end
end
