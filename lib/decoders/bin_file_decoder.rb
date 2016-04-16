require 'exceptions'
require 'decoders/positions'

# Library for decoding a binary file with custom structure
#
class BinFileDecoder
  INCREMENT = 12
  U8_DIRECTIVE = 'c'.freeze
  U16_DIRECTIVE = 'n'.freeze
  U32_DIRECTIVE = 'N'.freeze

  attr_accessor :file, :block

  def initialize(file, &block)
    @file = file
    @block = block
  end

  # Initializes and calls decode method for instance
  #
  # @param file [String] decoded from base64 file
  # @param &block [Proc] block of code
  #
  # @return [String, ArrayHash, ...] error message or array of decoded samples attributes/result of block invoking
  #
  def self.decode(file, &block)
    new(file, &block).decode
  end

  # Decodes binary file
  #   invokes block for each decoded sample if the block is given
  #
  # @return [String, Array<Hash, ...>] error message or array of decoded samples attributes/result of block invoking
  #
  # Example
  #   input: 'AB5lVwKQHwAlrL8BdgMGVwKMmwAloxgBeAMHVwKJFwAldmMBeQMHVwKFkwA'
  #   outout:
  #     [
  #       {
  #         sensor_id: 37,
  #         light: 7898,
  #         soil_moisture: 374,
  #         air_temperature: 742,
  #         capture_time: '2016-04-04T09:47:39.000Z'
  #       },
  #       {
  #         sensor_id: 37,
  #         light: 6780,
  #         soil_moisture: 379,
  #         air_temperature: 740,
  #         capture_time: '2016-04-04T10:02:39.000Z'
  #       }
  #     ]
  #   outout: 'Error: Cannot decode the sample #25'
  #
  def decode
    samples = []
    samples_count.times do |i|
      samples << if block
                   block.call(sample_attributes(i))
                 else
                   sample_attributes(i)
                 end
    end
    samples.compact
  rescue DecoderException => e
    return e.exception
  end

  # Generates attribute methods
  #   which will parse the file and fetch the values
  #
  # @param i [Integer] index of the number of expected samples      default = 0
  # @param directive [String] directive for decoding                default = U16_DIRECTIVE
  #
  # @return [String, Integer] error message or decoded value
  #   Example:
  #     input: '\xA3\x18'
  #     output: 41752
  #
  #     input: nil
  #     output: 'Error: Cannot decode the sample #15'
  #
  %w(sensor_id light soil_moisture air_temperature capture_time samples_count).each do |method_name|
    define_method method_name do |i = 0, directive = U16_DIRECTIVE|
      position = "Positions::#{method_name.upcase}".constantize
      encoded_value = file[range(position, i)]

      raise DecoderException.new("Error: Cannot decode the sample ##{i}") unless encoded_value

      encoded_value.unpack(directive).first
    end
  end

  private

  def version
    file[Positions::VERSION].unpack(U8_DIRECTIVE).first
  end

  def range(position, i)
    Range.new *position.map { |threshold| threshold + i * INCREMENT }
  end

  def sample_attributes(i)
    {
      sensor_id:       sensor_id(i),
      light:           light(i),
      soil_moisture:   soil_moisture(i),
      air_temperature: air_temperature(i),
      capture_time:    Time.at(capture_time(i, U32_DIRECTIVE)).utc
    }
  end
end
