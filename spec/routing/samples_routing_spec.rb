require 'rails_helper'

RSpec.describe SamplesController, type: :routing do
  describe 'routing' do
    it 'routes to #upload' do
      expect(post: '/samples/upload').to route_to('samples#upload')
    end

    it 'routes to #fetch' do
      expect(get: '/samples/fetch').to route_to('samples#fetch')
    end
  end
end
