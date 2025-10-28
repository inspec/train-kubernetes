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

      def parse_kubeconfig
        # Validate that kubeconfig option is provided
        unless @options[:kubeconfig]
          raise Train::UserError, "No kubeconfig file specified. Please provide a kubeconfig path using the 'kubeconfig' option."
        end

        kubeconfig_file = ::File.expand_path(@options[:kubeconfig])

        # Check if the kubeconfig file exists
        unless ::File.exist?(kubeconfig_file)
          raise Train::UserError, "Kubeconfig file not found at '#{kubeconfig_file}'. Please verify the path and try again."
        end

        # Attempt to load and parse the kubeconfig file
        begin
          config = K8s::Config.load_file(kubeconfig_file)
          @client = K8s::Client.config(config)
        rescue Psych::SyntaxError => e
          raise Train::UserError, "Invalid YAML syntax in kubeconfig file '#{kubeconfig_file}': #{e.message}"
        rescue K8s::Error => e
          raise Train::UserError, "Invalid kubeconfig file '#{kubeconfig_file}': #{e.message}"
        rescue StandardError => e
          raise Train::UserError, "Failed to load kubeconfig file '#{kubeconfig_file}': #{e.message}"
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
