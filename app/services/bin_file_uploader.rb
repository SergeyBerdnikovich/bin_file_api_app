require 'decoders/bin_file_decoder'

# Service for uploading file
#   1)fetches encoded file
#   2)decodes from base64
#   3)decodes binary file
#   4)stores to the db as Sample obj
#   5)returns result message
#
class BinFileUploader
  SUCCESS_STATUS = 'Uploaded!'.freeze
  FAIL_STATUS = 'Error: Nothing to upload!'.freeze

  attr_accessor :file, :samples

  def initialize(file)
    @file = Base64.decode64 file
  end

  # Initializes and calls upload method for instance
  #
  # @param file [String] decoded from base64 file
  #
  # @return [String] result status
  #
  def self.upload(file)
    new(file).upload
  end

  # Uploades decoded file to the db
  #   decodes file with BinFileDecoder
  #
  # @return [String] result status
  #   Example:
  #     Uploaded!
  #     Error: Future sample is detected!
  #     Error: Nothing to upload!
  #     Error: Cannot decode the sample #15
  #
  def upload
    ActiveRecord::Base.transaction do
      @samples = BinFileDecoder.decode(file) do |attributes|
        sample = Sample.new attributes
        SamplePresenter.present(sample) if sample.save
      end
    end

    prepare_response_message
  rescue FutureSampleException => e
    return e.exception
  end

  private

  def prepare_response_message
    if samples.is_a?(Array) && samples.blank?
      FAIL_STATUS
    elsif samples.is_a?(Array)
      SUCCESS_STATUS
    else
      samples
    end
  end
end
