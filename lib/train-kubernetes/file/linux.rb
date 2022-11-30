require 'train/file/remote/linux'
require 'train/extras/stat'

module TrainPlugins
  module TrainKubernetes
    module File
      class Linux < ::Train::File::Remote::Linux
        def initialize(backend, path, follow_symlink = true, pod:, **args)
          @backend = backend
          @path = path || ''
          @follow_symlink = follow_symlink
          @pod = pod
          @container = args[:container]
          @namespace = args[:namespace]

          sanitize_filename(path)
          super(backend, path, follow_symlink)
        end

        def content
          return @content if defined?(@content)

          @content = @backend.run_command("cat #{@spath} || echo -n",
                                          { pod: pod, namespace: namespace, container: container })
                             .stdout
          return @content unless @content.empty?

          @content = nil if directory? || size.nil? || (size > 0)
          @content
        end

        def content=(new_content)
          execute_result = @backend.run_command('base64 --help', { pod: pod, namespace: namespace, container: container })
          if execute_result.exitstatus != 0
            raise TransportError, "#{self.class} found no base64 binary for file writes"
          end

          unix_cmd = format("echo '%<base64>s' | base64 --decode > %<file>s",
                            base64: Base64.strict_encode64(new_content),
                            file: @spath)

          @backend.run_command(unix_cmd, { pod: pod, namespace: namespace, container: container })

          @content = new_content
        end

        def exist?
          @exist ||= begin
            f = @follow_symlink ? '' : " || test -L #{@spath}"
            @backend.run_command("test -e #{@spath}" + f,
                                 { pod: pod, namespace: namespace, container: container })
                    .exitstatus == 0
          end
        end

        def mounted
          @mounted ||=
            @backend.run_command("mount | grep -- ' on #{@path} '",
                                 { pod: pod, namespace: namespace, container: container })
        end

        def path
          return @path unless @follow_symlink && symlink?

          @link_path ||= read_target_path
        end

        def shallow_link_path
          return nil unless symlink?

          @shallow_link_path ||=
            @backend.run_command("readlink #{@spath}", { pod: pod, namespace: namespace, container: container })
                    .stdout
                    .chomp
        end

        def stat
          @stat ||= begin
            shell_escaped_path = @spath
            backend = @backend
            follow_symlink = @follow_symlink
            lstat = follow_symlink ? ' -L' : ''
            format = '--printf'
            res = backend.run_command("stat#{lstat} #{shell_escaped_path} 2>/dev/null #{format} '%s\n%f\n%U\n%u\n%G\n%g\n%X\n%Y\n%C'",
                                      { pod: pod, namespace: namespace, container: container })
            # ignore the exit_code: it is != 0 if selinux labels are not supported
            # on the system.

            fields = res.stdout.split("\n")
            return {} if fields.length != 9

            tmask = fields[1].to_i(16)
            selinux = fields[8]
            ## selinux security context string not available on esxi
            selinux = nil if (selinux == '?') || (selinux == '(null)') || (selinux == 'C')
            {
              type: Train::Extras::Stat.find_type(tmask),
              mode: tmask & 07777,
              owner: fields[2],
              uid: fields[3].to_i,
              group: fields[4],
              gid: fields[5].to_i,
              mtime: fields[7].to_i,
              size: fields[0].to_i,
              selinux_label: selinux
            }
          end
        end

        def source
          if @follow_symlink
            self.class.new(@backend, @path, false, pod: pod, container: container, namespace: namespace)
          else
            self
          end
        end

        private

        # Returns full path of a symlink target(real dest) or '' on symlink loop
        def read_target_path
          full_path = @backend.run_command("readlink -n #{@spath} -f",
                                           { pod: pod, namespace: namespace, container: container })
                              .stdout
          # Needed for some OSes like OSX that returns relative path
          # when the link and target are in the same directory
          if !full_path.start_with?('/') && full_path != ''
            full_path = ::File.expand_path("../#{full_path}", @spath)
          end
          full_path
        end

        attr_reader :pod, :container, :namespace, :path
      end
    end
  end
end
