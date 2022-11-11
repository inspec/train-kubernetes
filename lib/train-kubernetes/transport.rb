require 'train-kubernetes/connection'

module TrainPlugins
  module TrainKubernetes
    class Transport < Train.plugin(1)
      name 'k8s'
      option :kubeconfig, default: ENV['KUBECONFIG'] || '~/.kube/config'
      option :pod, default: nil
      option :container, default: nil
      option :namespace, default: nil
      def connection(_instance_opts = nil)
        @connection ||= TrainPlugins::TrainKubernetes::Connection.new(@options)
      end
    end
  end
end
