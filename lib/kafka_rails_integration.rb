# frozen_string_literal: true

require 'kafka_rails_integration/concerns/model/changes_trackeable'
require 'kafka_rails_integration/concerns/model/eventeable'
require 'kafka_rails_integration/middlewares/deliver_messages'
require 'kafka_rails_integration/producer/producer'
require 'kafka_rails_integration/version'

require 'kafka'
require 'erb'
require 'yaml'

module KafkaRailsIntegration
  class Error < StandardError; end

  @config = {
    bootstrap_servers: 'localhost:9092',
    request_required_acks: 1,
    security_protocol: nil,
    sasl_mechanism: nil,
    sasl_username: nil,
    sasl_password: nil
  }
  @valid_config_keys = @config.keys
  @topics = []

  # Configure through hash
  def self.configure(opts = {})
    opts = opts.transform_keys(&:to_sym)
    opts.each { |k, v| @config[k] = v if @valid_config_keys.include? k }

    @client_id = opts[:client_id]

    (opts[:topics] || []).each do |topic|
      @topics << topic
      # TODO: allow more configs
      begin
        kafka_client.create_topic(topic, num_partitions: 1, replication_factor: 3)
      rescue Kafka::TopicAlreadyExists
        #  TODO: this sucks =D do it right lazy boy!
      end
    end
  end

  # Configure kafka through yaml file
  # @example KafkaRailsIntegration.configure_with('./config/kafka.yml')
  #
  # @param [String] path to kafka.yml config file.
  def self.configure_with(path)
    begin
      data = YAML.load(ERB.new(File.new(path).read).result, aliases: true)
      settings = data&.fetch(Rails.env)
    rescue Errno::ENOENT
      logger.warn("YAML configuration file couldn't be found.")
    rescue Psych::SyntaxError
      logger.warn('YAML configuration file contains invalid syntax.')
    end

    configure(settings) if settings
  end

  def self.config
    @config
  end

  def self.topics
    @topics
  end

  def self.kafka_client
    # TODO: Allow non sasl config
    @kafka_client ||= Kafka.new(
      config[:bootstrap_servers],
      client_id:,
      sasl_plain_username: config[:sasl_username],
      sasl_plain_password: config[:sasl_password],
      ssl_ca_certs_from_system: true
    )
  end

  def self.producer
    @producer ||= kafka_client.producer
  end

  def self.consumer
    @consumer ||= kafka_client.consumer
  end

  def self.logger
    @logger ||= Rails.logger
  end

  def self.client_id
    @client_id ||= Rails.application.class.module_parent_name
  end
end
