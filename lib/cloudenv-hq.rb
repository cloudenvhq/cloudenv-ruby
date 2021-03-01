require 'pathname'
require 'dotenv'
require 'tempfile'
require 'yaml'

class CloudenvHQ
  VERSION = '0.2.5'.freeze

  API_HOST = 'https://app.cloudenv.com'.freeze
  READ_PATH = '/api/v1/envs'.freeze

  def initialize(options = {})
    @environment = ENV['RAILS_ENV'] || ENV['RACK_ENV']
    @bearer = ENV['CLOUDENV_BEARER_TOKEN'] || `cat #{options[:bearer] || '~/.cloudenvrc'}`.strip
    @secret_key_filename = '.cloudenv-secret-key'
    @secret_key = Pathname.new(@secret_key_filename)

    until File.exist?(@secret_key) || @secret_key.expand_path == Pathname.new('/.cloudenv-secret-key')
      @secret_key = @secret_key.parent.parent + @secret_key_filename
    end

    if File.exist?(@secret_key)
      data = YAML.safe_load(IO.read(@secret_key))

      @app = data['slug']
      @secret_key = data['secret-key']
    else
      @app = ENV['CLOUDENV_APP_SLUG']
      @secret_key = ENV['CLOUDENV_APP_SECRET_KEY']
    end

    if @app && @secret_key
      if @environment
        data = `curl -s -H "Authorization: Bearer #{@bearer}" "https://app.cloudenv.com/api/v1/envs?name=#{@app}&environment=#{@environment}&version=#{VERSION}&lang=ruby" | openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"#{@secret_key}" 2> /dev/null`
        file = Tempfile.new('cloudenv')
        file.write(data)
        file.close
        Dotenv.load(file.path)
        file.unlink
      end

      data = `curl -s -H "Authorization: Bearer #{@bearer}" "https://app.cloudenv.com/api/v1/envs?name=#{@app}&environment=default&version=#{VERSION}&lang=ruby" | openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"#{@secret_key}" 2> /dev/null`
      file = Tempfile.new('cloudenv')
      file.write(data)
      file.close
      Dotenv.load(file.path)
      file.unlink
    else
      warn 'WARNING: cloudenv could not find a .cloudenv-secret-key in the directory path or values for both ENV["CLOUDENV_APP_SLUG"] and ENV["CLOUDENV_APP_SECRET_KEY"]'
    end
  end
end

CloudenvHQ.new(bearer: ENV['CLOUDENV_BEARER_PATH'])
