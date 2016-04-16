FactoryGirl.define do
  factory :sample do
    sequence(:sensor_id)
    sequence(:light)
    sequence(:soil_moisture)
    sequence(:air_temperature)
    capture_time Time.now
  end
end
