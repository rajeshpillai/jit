require "fileutils"

require_relative "./base"
require_relative "../config"
require_relative "../refs"

module Command
  class Init < Base

    def run
      path = @args.fetch(0, @dir)

      root_path = expanded_pathname(path)
      git_path  = root_path.join(".git")

      ["objects", "refs/heads"].each do |dir|
        begin
          FileUtils.mkdir_p(git_path.join(dir))
        rescue Errno::EACCES => error
          @stderr.puts "fatal: #{ error.message }"
          exit 1
        end
      end

      config = ::Config.new(git_path.join("config"))
      config.open_for_update
      config.set(["core", "bare"], false)
      config.save

      refs = Refs.new(git_path)
      refs.update_head("ref: #{ refs.default_ref.path }")

      puts "Initialized empty Jit repository in #{ git_path }"
      exit 0
    end

  end
end
