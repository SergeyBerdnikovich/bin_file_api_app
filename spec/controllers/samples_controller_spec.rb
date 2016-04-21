require 'rails_helper'

RSpec.describe SamplesController, type: :controller do
  describe 'GET /samples/fetch' do
    let!(:sample0) { create(:sample) }
    let!(:sample1) do
      create(:sample, sensor_id: 37,
                      light: 44_223,
                      soil_moisture: 374,
                      air_temperature: 774,
                      capture_time: Time.at(1_459_785_759).utc)
    end
    let!(:sample2) do
      create(:sample, sensor_id: 37,
                      light: 41_752,
                      soil_moisture: 376,
                      air_temperature: 775,
                      capture_time: Time.at(1_459_784_859).utc)
    end
    let(:samples) { SamplePresenter.present([sample2, sample1]) }

    context 'when request without params[:sensor_id]' do
      it 'fetches an error message' do
        get 'fetch'

        expect(response).to have_http_status(200)
        expect(response.body).to eq('Error: params[:sensor_id] is required!')
      end
    end

    context 'when samples with session id are not exist' do
      it 'fetchs an empty array' do
        get 'fetch', params: { sensor_id: 999 }

        expect(response).to have_http_status(200)
        expect(response.body).to eq('[]')
      end
    end

    context 'when samples with session id are exist' do
      it 'fetches samples by sensor_id only' do
        get 'fetch', params: { sensor_id: sample1.sensor_id }

        expect(response).to have_http_status(200)
        expect(response.body).to eq(samples.to_json)
      end

      it 'fetches samples by sensor_id and start_time' do
        get 'fetch', params: { sensor_id: sample1.sensor_id, start_time: Time.at(1_459_785_000).utc }

        expect(response).to have_http_status(200)
        expect(response.body).to eq(SamplePresenter.present(sample1).to_json)
      end

      it 'fetches samples by sensor_id and end_time' do
        get 'fetch', params: { sensor_id: sample1.sensor_id, end_time: Time.at(1_459_785_000).utc }

        expect(response).to have_http_status(200)
        expect(response.body).to eq(SamplePresenter.present(sample2).to_json)
      end

      it 'fetches samples by sensor_id, start_time and end_time' do
        get 'fetch', params: { sensor_id: sample1.sensor_id,
                               start_time: Time.at(1_459_785_000).utc,
                               end_time: Time.at(1_459_888_759).utc }

        expect(response).to have_http_status(200)
        expect(response.body).to eq(SamplePresenter.present(sample1).to_json)
      end
    end
  end

  describe 'POST /samples/upload' do
    let(:encoded_base64_file) { "AB5lVwKQHwAlrL8BdgMGVwKMmwAloxgBeAMHVwKJFwAldmMBeQ==\n" }

    context 'when request without params[:buffer]' do
      it 'fetches an error message' do
        post 'upload'

        expect(response).to have_http_status(200)
        expect(response.body).to eq('Error: params[:buffer] is required!')
      end
    end

    context 'when file is incorrect' do
      let(:error_message) { DecoderException.new('Error: Cannot decode the sample #3').to_json }

      it 'gets the error message' do
        post 'upload', params: { buffer: encoded_base64_file }

        expect(response).to have_http_status(200)
        expect(response.body).to eq(error_message)
      end
    end

    context 'when file is correct' do
      before { allow_any_instance_of(BinFileDecoder).to receive(:samples_count).and_return(2) }

      it 'gets success status' do
        post 'upload', params: { buffer: encoded_base64_file }

        expect(response).to have_http_status(200)
        expect(response.body).to eq(BinFileUploader::SUCCESS_STATUS)
      end

      context 'when some samples are exists' do
        let!(:sample1) { create(:sample, sensor_id: 37, capture_time: Time.at(1_459_785_759).utc) }

        it 'uploads only new samples' do
          post 'upload', params: { buffer: encoded_base64_file }

          expect(response).to have_http_status(200)
          expect(response.body).to eq(BinFileUploader::SUCCESS_STATUS)
          expect(Sample.count).to eq(2)
        end
      end

      context 'when some samples are from the future' do
        let(:error_message) { FutureSampleException.new('Error: Future sample is detected!').to_json }
        before { allow(Time).to receive(:now).and_return(Time.at(1_398_085_332).utc) }

        it 'rejects all samples which were tried to be uploaded' do
          post 'upload', params: { buffer: encoded_base64_file }

          expect(response).to have_http_status(200)
          expect(response.body).to eq(error_message)
          expect(Sample.count).to eq(0)
        end
      end
    end
  end
end
