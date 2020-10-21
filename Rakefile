require "rubygems"
require "bundler/setup"
require "rake"
require "rake/testtask"
require "rdoc/task"
require "rubygems/package_task"
require "./lib/cloud-env"

PKG_VERSION = Cloudenv::VERSION
PKG_NAME = "cloud-env".freeze
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}".freeze
RELEASE_NAME = "#{PKG_NAME}-#{PKG_VERSION}".freeze

PKG_FILES = FileList[
    "lib/*", "bin/*", "test/**/*", "[A-Z]*", "Rakefile", "html/**/*"
]

desc "Default Task"
task default: [:test]

# Run the unit tests
desc "Run all unit tests"
Rake::TestTask.new("test") do |t|
  t.libs << %w[lib test]
  t.pattern = "test/*/*_test.rb"
  t.verbose = true
end

# Make a console, useful when working on tests
desc "Generate a test console"
task :console do
  verbose(false) { sh "irb -I lib/ -r 'cloudenv'" }
end

# Genereate the RDoc documentation
desc "Create documentation"
Rake::RDocTask.new("doc") do |rdoc|
  rdoc.title = "CloudEnv - Keep your ENV vars synced between your team members"
  rdoc.rdoc_dir = "html"
  rdoc.rdoc_files.include("README.markdown")
  rdoc.rdoc_files.include("lib/*.rb")
end

# Genereate the package
spec = Gem::Specification.new do |s|
  #### Basic information.

  s.name = "cloudenv"
  s.version = PKG_VERSION
  s.summary = <<-EOF
   Keep your ENV vars synced between your team members
  EOF
  s.description = <<-EOF
   Keep your ENV vars synced between your team members
  EOF

  #### Which files are to be included in this gem?  Everything!  (Except CVS directories.)

  s.files = PKG_FILES

  #### Load-time details: library and application (you will need one or both).

  s.require_path = "lib"

  #### Author and project details.

  s.author = "CloudEnv"
  s.email = "support@cloudenv.com"
  s.homepage = "https://github.com/cloudenvhq/cloudenv-ruby"
end

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

desc "Report code statistics (KLOCs, etc) from the application"
task :stats do
  require "code_statistics"
  CodeStatistics.new(
    %w[Library lib],
    %w[Units test]
  ).to_s
end
