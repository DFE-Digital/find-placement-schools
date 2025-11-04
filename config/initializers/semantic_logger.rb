if Rails.env.development? || Rails.env.staging? || Rails.env.production? || Rails.env.review?
  Rails.application.configure do
    config.log_tags = [ :request_id ] # Prepend all log lines with the following tags
  end

  SemanticLogger.add_appender(io: $stdout, level: Rails.application.config.log_level, formatter: Rails.application.config.log_format)
  Rails.application.config.logger.info("Application logging to STDOUT")
end

# Monkey patch for ActiveRecord sql_runtime compatibility until Rails fixes
LAST_TESTED_VERSION = "4.18.0"

require "rails_semantic_logger/version"

unless RailsSemanticLogger::VERSION == LAST_TESTED_VERSION
  raise "rails_semantic_logger is version #{RailsSemanticLogger::VERSION} but the monkey patch was last tested on " \
          "#{LAST_TESTED_VERSION} - manually check if it can find the sql_runtime module."
end

module RailsSemanticLogger
  module ActiveRecord
    class LogSubscriber < ActiveSupport::LogSubscriber
      def self.runtime=(value)
        if ::ActiveRecord::RuntimeRegistry.respond_to?(:stats)
          ::ActiveRecord::RuntimeRegistry.stats.sql_runtime = value
        else
          ::ActiveRecord::RuntimeRegistry.sql_runtime = value
        end
      end

      def self.runtime
        if ::ActiveRecord::RuntimeRegistry.respond_to?(:stats)
          ::ActiveRecord::RuntimeRegistry.stats.sql_runtime ||= 0
        else
          ::ActiveRecord::RuntimeRegistry.sql_runtime ||= 0
        end
      end
    end
  end
end
