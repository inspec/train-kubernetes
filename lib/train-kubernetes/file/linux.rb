require 'train/file/remote/linux'

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

          @content = @backend.run_command("cat #{@spath} || echo -n", { pod: pod, namespace: nil, container: nil }).stdout
          return @content unless @content.empty?

          @content = nil if directory? || size.nil? || (size > 0)
          @content
        end

        private

        attr_reader :pod, :container, :namespace, :path
      end
    end
  end
end
