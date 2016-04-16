require 'rails_helper'
require 'decoders/bin_file_decoder'

RSpec.describe BinFileDecoder, type: :decoder do
  describe '#decode' do
    let(:encoded_file) do
      "\x00\x1EeW\x02\x90\x1F\x00%\xAC\xBF\x01v\x03\x06W\x02\x8C\x9B\x00%\xA3\x18\x01x\x03\aW\x02\x89\x17\x00%vc\x01y"
    end

    context 'when file is broken' do
      let(:error_message) { DecoderException.new('Error: Cannot decode the sample #3').to_s }

      it 'raises an exception and returns error message' do
        expect(described_class.decode(encoded_file).to_s).to match(error_message)
      end
    end

    context 'when file is correct' do
      before { allow_any_instance_of(BinFileDecoder).to receive(:samples_count).and_return(2) }

      context 'and without &block' do
        let(:decoded_samples) do
          [
            {
              sensor_id: 37,
              light: 44_223,
              soil_moisture: 374,
              air_temperature: 774,
              capture_time: Time.parse('2016-04-04 19:02:39').utc
            },
            {
              sensor_id: 37,
              light: 41_752,
              soil_moisture: 376,
              air_temperature: 775,
              capture_time: Time.parse('2016-04-04 18:47:39').utc
            }
          ]
        end

        it 'returns an array of samples' do
          expect(described_class.decode(encoded_file)).to eq(decoded_samples)
        end
      end

      context 'and with &block' do
        it 'returns an array of results of block invoking' do
          expect(described_class.decode(encoded_file){ |attributes| attributes[:sensor_id] }).to eq([37, 37])
        end
      end
    end
  end
end
