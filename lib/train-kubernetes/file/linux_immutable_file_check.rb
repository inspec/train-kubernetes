require 'inspec/resources/file'
require 'inspec/exceptions'

module TrainPlugins
  module TrainKubernetes
    module File
      class LinuxImmutableFileCheck < Inspec::Resources::LinuxImmutableFlagCheck
        def initialize(inspec, file, pod:, container: nil, namespace: nil)
          @pod = pod
          @container = container
          @namespace = namespace
          super(inspec, file)
        end

        def find_utility_or_error(utility_name)
          %W(/usr/sbin/#{utility_name} /sbin/#{utility_name} /usr/bin/#{utility_name} /bin/#{utility_name} #{utility_name}).each do |cmd|
            if inspec.backend
                     .run_command("sh -c 'type \"#{cmd}\"'", { pod: pod, container: container, namespace: namespace })
                     .exit_status.to_i == 0
              return cmd
            end
          end

          raise Inspec::Exceptions::ResourceFailed, "Could not find `#{utility_name}`"
        end

        def is_immutable?
          # Check if lsattr is available. In general, all linux system has lsattr & chattr
          # This logic check is valid for immutable flag set with chattr
          utility = find_utility_or_error('lsattr')

          utility_cmd = inspec.backend.run_command("#{utility} #{file_path}",
                                                   { pod: pod, container: container, namespace: namespace })

          raise Inspec::Exceptions::ResourceFailed, "Executing #{utility} #{file_path} failed: #{utility_cmd.stderr}" if utility_cmd.exit_status.to_i != 0

          # General output for lsattr file_name is:
          # ----i---------e----- file_name
          # The fifth char resembles the immutable flag. Total 20 flags are allowed.
          lsattr_info = utility_cmd.stdout.strip.squeeze(' ')
          lsattr_info =~ /^.{4}i.{15} .*/
        end

        private

        attr_reader :pod, :container, :namespace
      end
    end
  end
end
