require 'rails_helper'
require 'exceptions'

RSpec.describe Sample, type: :model do
  describe 'custom validators' do
    describe 'future_sample' do
      context 'when capture_time is a future' do
        let(:sample) { build(:sample, capture_time: Time.now + 1.year) }

        it 'raises an error' do
          expect { sample.save }.to raise_error(FutureSampleException, 'Error: Future sample is detected!')
        end
      end

      context 'when capture_time is a past' do
        let(:sample) { build(:sample) }

        it "doesn't raise an error" do
          expect { sample.save }.to_not raise_error
        end
      end
    end

    describe 'one_capture_time_per_sensor_id' do
      let!(:sample) { create(:sample, sensor_id: 1, capture_time: Time.parse('2015-11-11')) }

      context 'when dublicate is found' do
        let(:duplicated_sample) { build(:sample, sensor_id: 1, capture_time: Time.parse('2015-11-11')) }
        let(:message) do
          "Warning: Duplicates(sensor_id: #{sample.sensor_id}, capture_time: #{sample.capture_time}) are detected!"
        end

        it 'logs the warning' do
          expect(Rails.logger).to receive(:warn).with(message)

          duplicated_sample.save
        end

        it 'adds error to sample' do
          duplicated_sample.save

          expect(duplicated_sample.errors.messages[:sensor_id].first).to eq(message)
        end

        it 'will not be valid' do
          duplicated_sample.save

          expect(duplicated_sample).to_not be_valid
        end

        it 'will not change sample count' do
          expect { duplicated_sample.save }.to_not change { Sample.count }
        end
      end

      context 'when dublicate is not found' do
        let(:valid_sample) { build(:sample, sensor_id: 1, capture_time: Time.parse('2015-11-12')) }

        it 'will change sample count' do
          expect { valid_sample.save }.to change { Sample.count }.by(1)
        end

        it 'will be valid' do
          valid_sample.save

          expect(valid_sample).to be_valid
        end
      end
    end
  end
end
