# frozen_string_literal: true

require 'kafka_rails_integration/concerns/model/changes_trackeable'
require 'kafka_rails_integration/concerns/model/eventeable'
require 'kafka_rails_integration/middlewares/deliver_messages'
require 'kafka_rails_integration/producer/producer'
require 'kafka_rails_integration/version'

require 'erb'
require 'yaml'

module KafkaRailsIntegration
  class Error < StandardError; end

  # Configure through hash
  def self.configure(opts = {})
    @config = opts.slice(config.keys)
  end

  # Configure through yaml file
  def self.configure_with(path)
    begin
      environment = defined?(Rails) ? Rails.env : ENV["RACK_ENV"]
      settings = YAML.load(ERB.new(File.new(path).read).result, aliases: true)[environment]
      @config = settings
    rescue Errno::ENOENT
      raise "YAML configuration file couldn't be found."
    rescue Psych::SyntaxError
      raise 'YAML configuration file contains invalid syntax.'
    end

    configure(config)
  end

  def self.config
    @config ||= {
      bootstrap_servers: 'localhost:9092',
      request_required_acks: 1,
      sasl_mechanism: nil,
      sasl_username: nil,
      sasl_password: nil
    }
  end
end
