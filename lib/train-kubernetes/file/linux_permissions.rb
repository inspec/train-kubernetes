module TrainPlugins
  module TrainKubernetes
    module File
      class LinuxPermissions < Inspec::Resources::UnixFilePermissions
        def initialize(inspec, pod:, namespace: nil, container: nil)
          @pod = pod
          @namespace = namespace
          @container = container
          super(inspec)
        end

        def check_file_permission_by_user(access_type, user, path)
          flag = permission_flag(access_type)
          perm_cmd = "su -s /bin/sh -c \"test -#{flag} #{path}\" #{user}"
          cmd = inspec.backend.run_command(perm_cmd, { pod: pod, namespace: namespace, container: container })
          cmd.exit_status == 0
        end

        private

        attr_reader :pod, :container, :namespace
      end
    end
  end
end
