require "train"
require "k8s-ruby"
require "train-kubernetes/platform"
require "train-kubernetes/kubectl_client"

module TrainPlugins
  module TrainKubernetes
    class Connection < Train::Plugins::Transport::BaseConnection
      include TrainPlugins::TrainKubernetes::Platform

      def initialize(options)
        super(options)
        @pod = options[:pod] || options[:path]&.gsub("/", "")
        @container = options[:container]
        @namespace = options[:namespace] || options[:host]
        parse_kubeconfig
        connect
      end

      attr_accessor :client

      def connect
        @client.apis(prefetch_resources: true)
      rescue Excon::Error::Socket => e
        logger.error e.message
        exit
      end

      def uri
        "kubernetes://#{unique_identifier}"
      end

      def unique_identifier
        @client.transport.server.gsub(%r{(http|https)\:\/\/}, "") || "default"
      end

      # Parse and validate the kubeconfig file
      #
      # This method loads the Kubernetes configuration from the specified kubeconfig file,
      # validates its existence and format, and creates a K8s client from the configuration.
      #
      # @raise [Train::UserError] if kubeconfig is not specified
      # @raise [Train::UserError] if kubeconfig file does not exist
      # @raise [Train::UserError] if kubeconfig has invalid YAML syntax
      # @raise [Train::UserError] if kubeconfig has invalid Kubernetes configuration
      # @raise [Train::UserError] if kubeconfig fails to load for any other reason
      #
      # @return [void]
      #
      # @example Error messages
      #   "No kubeconfig file specified. Please provide a kubeconfig path."
      #   "Kubeconfig file not found at '/path/to/config'. Please check the path and try again."
      #   "Invalid YAML syntax in kubeconfig file '/path/to/config': <error details>"
      #   "Invalid kubeconfig file '/path/to/config': <error details>"
      #
      def parse_kubeconfig
        kubeconfig_file = @options[:kubeconfig] if @options[:kubeconfig]

        # Validate kubeconfig file exists
        unless kubeconfig_file
          raise Train::UserError, "No kubeconfig file specified. Please provide a kubeconfig path."
        end

        expanded_path = ::File.expand_path(kubeconfig_file)

        unless ::File.exist?(expanded_path)
          raise Train::UserError, "Kubeconfig file not found at '#{expanded_path}'. Please check the path and try again."
        end

        # Attempt to load and parse the kubeconfig
        begin
          config = K8s::Config.load_file(expanded_path)
          @client = K8s::Client.config(config)
        rescue Psych::SyntaxError => e
          raise Train::UserError, "Invalid YAML syntax in kubeconfig file '#{expanded_path}': #{e.message}"
        rescue K8s::Error => e
          raise Train::UserError, "Invalid kubeconfig file '#{expanded_path}': #{e.message}"
        rescue StandardError => e
          raise Train::UserError, "Failed to load kubeconfig from '#{expanded_path}': #{e.message}"
        end
      end

      private

      attr_reader :pod, :container, :namespace

      def run_command_via_connection(cmd, opts = {}, &_data_handler)
        KubectlClient.new(pod: opts[:pod] || pod,
                          container: opts[:container] || container,
                          namespace: opts[:namespace] || namespace)
          .execute(cmd)
      end

      def file_via_connection(path, **args)
        TrainPlugins::TrainKubernetes::File::Linux.new(self, path, pod: args[:pod], container: args[:container], namespace: args[:namespace])
      end
    end
  end
end
