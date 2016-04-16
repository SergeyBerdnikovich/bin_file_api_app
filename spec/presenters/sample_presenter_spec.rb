require 'rails_helper'

RSpec.describe SamplePresenter, type: :presenter do
  describe '#present' do
    let(:sample) { create(:sample) }

    it 'returns valid sample data' do
      expect(described_class.present(sample).first).to include(:sensor_id,
                                                               :light,
                                                               :soil_moisture,
                                                               :air_temperature,
                                                               :capture_time)
    end
  end
end
