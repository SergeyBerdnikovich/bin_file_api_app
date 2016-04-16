require 'rails_helper'
require 'exceptions'

RSpec.describe BinFileUploader, type: :service do
  describe '#upload' do
    let(:encoded_base64_file) { "AB5lVwKQHwAlrL8BdgMGVwKMmwAloxgBeAMHVwKJFwAldmMBeQ==\n" }

    let(:encoded_file) do
      "\x00\x1EeW\x02\x90\x1F\x00%\xAC\xBF\x01v\x03\x06W\x02\x8C\x9B\x00%\xA3\x18\x01x\x03\aW\x02\x89\x17\x00%vc\x01y"
    end

    it 'decode from base64' do
      expect(Base64).to receive(:decode64).with(encoded_base64_file).and_return(encoded_file)

      described_class.upload(encoded_base64_file)
    end

    context 'when file is not correct' do
      let(:error_message) { DecoderException.new('Error: Cannot decode the sample #3').to_s }

      it 'raises an exception and returns error message' do
        expect(described_class.upload(encoded_base64_file).to_s).to match(error_message)
      end
    end

    context 'when file is correct' do
      before { allow_any_instance_of(BinFileDecoder).to receive(:samples_count).and_return(2) }

      it 'returns an success status' do
        expect(described_class.upload(encoded_base64_file)).to eq(BinFileUploader::SUCCESS_STATUS)
      end

      it 'stores decoded samples' do
        expect { described_class.upload(encoded_base64_file) }.to change { Sample.count }.from(0).to(2)
      end

      context 'when some sample is from future' do
        let(:error_message) { FutureSampleException.new('Error: Future sample is detected!').to_s }

        before { allow(Time).to receive(:now).and_return(Time.parse('2016-04-04 18:55:39').utc) }

        it 'returns an error' do
          expect(described_class.upload(encoded_base64_file).to_s).to eq(error_message)
        end

        it 'rejects all semples with transaction rollback' do
          expect { described_class.upload(encoded_base64_file) }.to_not change { Sample.count }
        end
      end

      context 'when nothing to upload' do
        let!(:sample1) { create(:sample, sensor_id: 37, capture_time: Time.parse('2016-04-04 19:02:39').utc) }
        let!(:sample2) { create(:sample, sensor_id: 37, capture_time: Time.parse('2016-04-04 18:47:39').utc) }

        it 'returns an error' do
          expect(described_class.upload(encoded_base64_file).to_s).to eq(BinFileUploader::FAIL_STATUS)
        end
      end

      context 'when some samples already exist' do
        let!(:sample) { create(:sample, sensor_id: 37, capture_time: Time.parse('2016-04-04 19:02:39').utc) }

        it 'stores only new samples' do
          expect { described_class.upload(encoded_base64_file) }.to change { Sample.count }.from(1).to(2)
        end
      end
    end
  end
end
