require "pathname"
require "dotenv"

class CloudenvHQ
  VERSION = "0.1.0".freeze

  API_HOST = "https://app.cloudenv.com".freeze
  READ_PATH = "/api/v1/envs".freeze

  def initialize(options={})
    @environment = ENV["RAILS_ENV"] || ENV["RACK_ENV"]
    @bearer = `cat #{options[:bearer] || "~/.cloudenvrc"}`.strip
    @secret_key_filename = ".cloudenv-secret-key"
    @secret_key = Pathname.new(@secret_key_filename)

    until File.exists?(@secret_key) || @secret_key.expand_path == Pathname.new("/.cloudenv-secret-key")
      @secret_key = @secret_key.parent.parent + @secret_key_filename
    end

    if File.exists?(@secret_key)
      @app, @secret_key = IO.read(@secret_key).split

      if @environment
        data = `curl -s -H "Authorization: Bearer #{@bearer}" "https://app.cloudenv.com/api/v1/envs?name=#{@app}&environment=#{@environment}" | openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"#{@secret_key}" 2> /dev/null`
        file = Tempfile.new("cloudenv")
        file.write(data)
        file.close
        Dotenv.load(file.path)
        file.unlink
      end

      data = `curl -s -H "Authorization: Bearer #{@bearer}" "https://app.cloudenv.com/api/v1/envs?name=#{@app}&environment=default" | openssl enc -a -aes-256-cbc -md sha512 -d -pass pass:"#{@secret_key}" 2> /dev/null`
      file = Tempfile.new("cloudenv")
      file.write(data)
      file.close
      Dotenv.load(file.path)
      file.unlink
    else
      warn "WARNING: cloudenv could not find a .cloudenv-secret-key in the directory path"
    end
  end
end

CloudenvHQ.new(bearer: ENV["CLOUDENV_BEARER_PATH"])