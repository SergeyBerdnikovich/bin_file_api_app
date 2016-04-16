# Api controller for uploading buffered binary file and fetching samples
#
class SamplesController < ApplicationController
  before_action :check_upload_params, only: :upload
  before_action :check_fetch_params, only: :fetch

  # POST /samples/upload
  #
  # Uploads file with encoded samples
  #
  # @param buffer [String] encoded in base64 binary file wrapped into json object   (mandatory)
  #   Example:
  #     '{ "buffer": "AB5lVwKQHwAlrL8BdgMGVwKMmwAloxgBeAMHVwKJFwAldmMBeQMHVwKFkwA" }'
  #
  # @return [String] succes_status or error message in json format
  #   Example:
  #     Uploaded!
  #     Error: Future sample is detected!
  #     Error: Nothing to upload!
  #     Error: Cannot decode the sample #15
  #
  def upload
    render json: BinFileUploader.upload(params[:buffer])
  end

  # GET /samples/fetch
  #
  # Fetches decoded samples
  #
  # @param sensor_id [String] sensor id                         (mandatory)
  #   Example:
  #     '37'
  # @param start_time [String] start threshold of capture_time  (optional)
  #   Example:
  #     '2016-12-23'
  #     '1460713647'
  #     '2016/03/14'
  # @param end_time [String] end threshold of capture_time      (optional)
  #   Example:
  #     '2016-12-23'
  #     '1460713647'
  #     '2016/03/14'
  #
  #  @return [String] array of samples in json format
  #    Example:
  #      '[
  #         {
  #           "sensor_id":37,
  #           "light":7898,
  #           "soil_moisture":374,
  #           "air_temperature":742,
  #           "capture_time":"2016-04-04T09:47:39.000Z"
  #         },
  #         {
  #           "sensor_id":37,
  #           "light":6780,
  #           "soil_moisture":379,
  #           "air_temperature":740,
  #           "capture_time":"2016-04-04T10:02:39.000Z"
  #         }
  #       ]'
  #
  def fetch
    render json: SampleFetchQuery.call(params[:sensor_id], params[:start_time], params[:end_time])
  end

  private

  def check_upload_params
    render json: 'Error: params[:buffer] is required!' if params[:buffer].blank?
  end

  def check_fetch_params
    render json: 'Error: params[:sensor_id] is required!' if params[:sensor_id].blank?
  end
end
