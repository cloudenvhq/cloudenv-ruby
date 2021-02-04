Gem::Specification.new do |s|
  s.name = "cloudenv-hq"
  s.version = "0.1.2"
  s.license = "MIT"
  s.version = "#{s.version}-alpha-#{ENV['TRAVIS_BUILD_NUMBER']}" if ENV["TRAVIS"]
  s.date = "2020-10-10"
  s.summary = "Keep your ENV vars synced between your team members"
  s.email = "support@cloudenv.com"
  s.homepage = "https://github.com/cloudenvhq/cloudenv-ruby"
  s.description = "Keep your ENV vars synced between your team members."
  s.authors = ["Lucas Carlson"]
  s.files = ["install.rb", "lib", "lib/cloudenv-hq.rb", "LICENSE", "Rakefile", "README.markdown", "cloudenv-hq.gemspec", "test", "test/base", "test/base/base_test.rb", "test/data", "test/test_helper.rb"]
  s.rubyforge_project = "cloudenv-hq"
  s.add_dependency "dotenv"
  s.add_development_dependency "rake"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "test-unit"
end
