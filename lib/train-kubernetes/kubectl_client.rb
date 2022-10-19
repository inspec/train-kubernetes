require 'mixlib/shellout'

module TrainPlugins
  module TrainKubernetes
    class KubectlClient
      attr_reader :pod, :container

      def initialize(pod:, container: nil)
        @pod = pod
        @container = container
      end

      def execute(command, stdin: true, tty: true)
        instruction = build_instruction(command, stdin, tty)
        shell = Mixlib::ShellOut.new(instruction)
        shell.run_command
      end

      private

      def shell
        @shell ||= Mixlib::ShellOut.new(instruction)
      end

      def build_instruction(command, stdin, tty)
        ['kubectl exec'].tap do |arr|
          arr << '--stdin' if stdin
          arr << '--tty' if tty
          arr << pod if pod
          arr << command
        end.join("\s")
      end
    end
  end
end
