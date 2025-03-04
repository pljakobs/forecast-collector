require 'net/http'
require 'influxdb-client'

require_relative 'flux_writer'
require_relative 'forecast'
require_relative 'forecast_solar'
require_relative 'solcast'

class Loop
  def initialize(config:)
    @config = config
  end

  attr_reader :config

  def self.start(config:, max_count: nil)
    new(config:).start(max_count)
  end

  def start(max_count)
    push_to_influx(data)
  end

  private

  attr_accessor :count

  def push_to_influx(data)
    return unless data

    print '  Pushing forecast to InfluxDB ... '
    FluxWriter.push(config:, data:)
    puts 'OK'
  end

  def make_forecast
    case config.forecast_provider
    when 'forecast.solar'
      ForecastSolar.new(config:)
    when 'solcast'
      Solcast.new(config:)
    end
  end
end
