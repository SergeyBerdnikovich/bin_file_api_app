require 'rails_helper'
require 'decoders/bin_file_decoder'

RSpec.describe 'Samples API', type: :request do
  describe 'uploading and fetching file' do
    let(:encoded_base64_file) { "AB5lVwKQHwAlrL8BdgMGVwKMmwAloxgBeAMHVwKJFwAldmMBeQ==\n" }
    let(:sample1) do
      build(:sample, sensor_id: 37,
                     light: 44_223,
                     soil_moisture: 374,
                     air_temperature: 774,
                     capture_time: Time.parse('2016-04-04 19:02:39').utc)
    end
    let(:sample2) do
      build(:sample, sensor_id: 37,
                     light: 41_752,
                     soil_moisture: 376,
                     air_temperature: 775,
                     capture_time: Time.parse('2016-04-04 18:47:39').utc)
    end

    before { allow_any_instance_of(BinFileDecoder).to receive(:samples_count).and_return(2) }

    context 'positive scenario' do
      it 'uploads encoded file and fetches decoded samples' do
        post '/samples/upload', params: { buffer: encoded_base64_file }

        expect(response).to have_http_status(200)
        expect(response.body).to eq(BinFileUploader::SUCCESS_STATUS)
        expect(Sample.count).to eq(2)

        get '/samples/fetch', params: { sensor_id: 37 }

        expect(response).to have_http_status(200)
        expect(response.body).to eq(SamplePresenter.present([sample2, sample1]).to_json)
      end
    end
  end
end
