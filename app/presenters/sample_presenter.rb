# Presentes the samples by custom format
#
class SamplePresenter
  attr_accessor :samples

  def initialize(samples)
    @samples = Array.wrap(samples)
  end

  # Initializes and calls present method
  #
  # @param sample [Sample] sample obj
  #
  # @return [Array<Hash>] array of hashes with sample attributes
  #
  def self.present(samples)
    new(samples).present
  end

  # Generates samples data
  #
  # @return [Array<Hash>] array of hashes with sample attributes
  #   Example:
  #     input:
  #       Sample {
  #         id: 1,
  #         sensor_id: 37,
  #         light: 7898,
  #         soil_moisture: 374,
  #         air_temperature: 742,
  #         capture_time: '2016-04-04T09:47:39.000Z'
  #       }
  #     output:
  #       {
  #         sensor_id: 37,
  #         light: 7898,
  #         soil_moisture: 374,
  #         air_temperature: 742,
  #         capture_time: '2016-04-04T09:47:39.000Z'
  #       }
  #
  def present
    samples.map do |sample|
      {
        sensor_id:       sample.sensor_id,
        light:           sample.light,
        soil_moisture:   sample.soil_moisture,
        air_temperature: sample.air_temperature,
        capture_time:    sample.capture_time
      }
    end
  end
end
