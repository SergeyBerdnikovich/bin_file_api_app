# Custom quoery for fetching samples
#
class SampleFetchQuery
  attr_accessor :sensor_id, :start_time, :end_time

  def initialize(sensor_id, start_time, end_time)
    @sensor_id = sensor_id
    @start_time = parse_time_format(start_time) if start_time.present?
    @end_time = parse_time_format(end_time) if end_time.present?
  end

  # Initializes and calls method for generating the query
  #
  # @param sensor_id [Integer, String] sensor id
  # @param start_time [Time, NilClass] start time threshold or nil     default = nil
  # @param end_time [Time, NilClass] end time threshold or nil         default = nil
  #
  # @return [Array<Hash>] array of hashes with sample attributes
  #
  def self.call(sensor_id, start_time = nil, end_time = nil)
    new(sensor_id, start_time, end_time).call
  end

  # Generates the query for fetching samples
  #
  # @return [Array<Hash>] array of hashes with sample attributes
  #   Example:
  #     input:
  #       sensor_id: 37
  #       start_time: '2016-11-12'
  #       end_time: '2017/03/22'
  #     output:
  #       [
  #         {
  #           sensor_id: 37,
  #           light: 7898,
  #           soil_moisture: 374,
  #           air_temperature: 742,
  #           capture_time: '2016-04-04T09:47:39.000Z'
  #         }
  #       ]
  #
  def call
    query = Sample.where(sensor_id: sensor_id)
    query = query.where('capture_time >= ?', start_time) if start_time
    query = query.where('capture_time <= ?', end_time) if end_time

    SamplePresenter.present query
  end

  private

  def parse_time_format(time)
    Time.parse(time).utc
  rescue
    Time.at(time.to_i).utc
  rescue
    nil
  end
end
