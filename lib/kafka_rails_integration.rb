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

  @config = {
    bootstrap_servers: 'localhost:9092',
    request_required_acks: 1,
    sasl_mechanism: nil,
    sasl_username: nil,
    sasl_password: nil
  }

  # Configure through hash
  def self.configure(opts = {})
    @config = opts.slice(@config.keys)
  end

  # Configure kafka through yaml file
  # @example KafkaRailsIntegration.configure_with('./config/kafka.yml')
  #
  # @param [String] path to kafka.yml config file.
  def self.configure_with(path)
    begin
      environment = defined?(Rails) ? Rails.env : ENV["RACK_ENV"]
      settings = YAML.load(ERB.new(File.new(path).read).result, aliases: true)[environment]
    rescue Errno::ENOENT
      logger.warn("YAML configuration file couldn't be found.")
    rescue Psych::SyntaxError
      logger.warn('YAML configuration file contains invalid syntax.')
    end

    configure(settings)
  end

  def self.config
    @config
  end

  # Returns the default logger, which is either a Rails logger of stdout logger
  #
  # @example Get the default logger
  #   config.default_logger
  #
  # @return [ Logger ] The default Logger instance.
  def default_logger
    defined?(Rails) ? Rails.logger : ::Logger.new($stdout)
  end

  # Returns the logger, or defaults to Rails logger or stdout logger.
  #
  # @example Get the logger.
  #   config.logger
  #
  # @return [ Logger ] The configured logger or a default Logger instance.
  def logger
    @logger = default_logger unless defined?(@logger)
    @logger
  end

  # Sets the logger for Mongoid to use.
  #
  # @example Set the logger.
  #   config.logger = Logger.new($stdout, :warn)
  #
  # @return [ Logger ] The newly set logger.
  def logger=(logger)
    @logger = logger
  end
end
