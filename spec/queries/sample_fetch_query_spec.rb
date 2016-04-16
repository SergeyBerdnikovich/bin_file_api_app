require 'rails_helper'
require 'exceptions'

RSpec.describe SampleFetchQuery, type: :query do
  let(:sensor_id) { '12345' }
  let(:start_time) { '2014-11-16' }
  let(:end_time) { '2015-12-14' }

  describe '#call' do
    let!(:sample) { create(:sample) }
    let!(:sample1) { create(:sample, sensor_id: sensor_id, capture_time: Time.parse('2016-03-12')) }
    let!(:sample2) { create(:sample, sensor_id: sensor_id, capture_time: Time.parse('2015-08-12')) }
    let!(:sample3) { create(:sample, sensor_id: sensor_id, capture_time: Time.parse('2014-07-12')) }
    let(:samples1) { [sample3, sample2, sample1] }
    let(:samples2) { [sample3, sample2] }
    let(:samples3) { [sample2, sample1] }

    context 'when params[:sensor_id] is exist only' do
      it 'finds the sample' do
        expect(described_class.call(sensor_id)).to eq(SamplePresenter.present(samples1))
      end
    end

    context 'when params[:sensor_id] and params[:start_time] are exist only' do
      it 'finds samples which newer than start_time' do
        expect(described_class.call(sensor_id, start_time)).to eq(SamplePresenter.present(samples3))
      end
    end

    context 'when params[:sensor_id] and params[:end_time] are exist only' do
      it 'finds samples which older than end_time' do
        expect(described_class.call(sensor_id, nil, end_time)).to eq(SamplePresenter.present(samples2))
      end
    end

    context 'when params[:sensor_id], params[:start_time] and params[:end_time] are exist' do
      it 'finds samples which newer than start_time and older than end_time' do
        expect(described_class.call(sensor_id, start_time, end_time)).to eq(SamplePresenter.present(sample2))
      end
    end

    context 'other formats' do
      let(:start_time) { '2014/11/16' }
      let(:end_time) { '2015.12.14' }

      it 'accept Y/m/d and Y.m.d formats' do
        expect(described_class.call(sensor_id, start_time, end_time)).to eq(SamplePresenter.present(sample2))
      end
    end
  end
end
