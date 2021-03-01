require 'pathname'
require 'dotenv'
require 'tempfile'
require 'yaml'

class CloudenvHQ
  VERSION = '0.2.8'.freeze

  API_HOST = 'https://app.cloudenv.com'.freeze
  READ_PATH = '/api/v1/envs'.freeze

  def initialize(options = {})
    @environment = ENV['RAILS_ENV'] || ENV['RACK_ENV']

    if ENV['CLOUDENV_BEARER_TOKEN'] || options[:bearer]
      @bearer = ENV['CLOUDENV_BEARER_TOKEN'] || options[:bearer]
    else
      @bearer_filename = File.expand_path(ENV['CLOUDENV_BEARER_PATH'] || '~/.cloudenvrc')
      @bearer = IO.read(@bearer_filename).to_s.strip if File.exist?(@bearer_filename)
    end

    if ENV['CLOUDENV_APP_SLUG'] && ENV['CLOUDENV_APP_SECRET_KEY']
      @app = ENV['CLOUDENV_APP_SLUG']
      @secret_key = ENV['CLOUDENV_APP_SECRET_KEY']
    else
      @secret_key_filename = File.expand_path(ENV['CLOUDENV_APP_SECRET_KEY_PATH'] || '.cloudenv-secret-key')
      @secret_key = Pathname.new(@secret_key_filename)

      until File.exist?(@secret_key) || @secret_key.expand_path == Pathname.new('/.cloudenv-secret-key')
        @secret_key = @secret_key.parent.parent + @secret_key_filename.split('/').last
      end

      if File.exist?(@secret_key)
        data = YAML.safe_load(IO.read(@secret_key))

        @app = data['slug']
        @secret_key = data['secret-key']
      end
    end

    if @bearer && @app && @secret_key
      if @environment
        data = `curl -s -H "Authorization: Bearer #{@bearer}" "#{API_HOST}#{READ_PATH}?name=#{@app}&environment=#{@environment}&version=#{VERSION}&lang=ruby" | openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"#{@secret_key}" 2> /dev/null`
        file = Tempfile.new('cloudenv')
        file.write(data.encode('UTF-8', invalid: :replace, replace: ''))
        file.close
        Dotenv.load(file.path)
        file.unlink
      end

      data = `curl -s -H "Authorization: Bearer #{@bearer}" "#{API_HOST}#{READ_PATH}?name=#{@app}&environment=default&version=#{VERSION}&lang=ruby" | openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"#{@secret_key}" 2> /dev/null`
      file = Tempfile.new('cloudenv')
      file.write(data.encode('UTF-8', invalid: :replace, replace: ''))
      file.close
      puts 1
      Dotenv.load(file.path)
      file.unlink

    else
      warn 'WARNING: cloudenv could not find a .cloudenv-secret-key in the directory path or values for both ENV["CLOUDENV_APP_SLUG"] and ENV["CLOUDENV_APP_SECRET_KEY"]'
    end
  end
end

CloudenvHQ.new(bearer: ENV['CLOUDENV_BEARER_PATH'])
