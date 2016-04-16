# == Schema Information
#
# Table name: samples
#
#  sensor_id        :integer
#  light            :integer
#  soil_moisture    :integer
#  air_temperature  :integer
#  capture_time     :datetime
#
# Indexes
#
#  index_samples_on_sensor_id_and_capture_time  (sensor_id, capture_time)
#
class Sample < ApplicationRecord
  validate :future_sample, on: :create
  validate :one_capture_time_per_sensor_id, on: :create

  private

  def future_sample
    raise FutureSampleException.new('Error: Future sample is detected!') if capture_time > Time.current
  end

  def one_capture_time_per_sensor_id
    if Sample.where(sensor_id: sensor_id, capture_time: capture_time).first
      message = "Warning: Duplicates(sensor_id: #{sensor_id}, capture_time: #{capture_time}) are detected!"
      Rails.logger.warn message
      errors.add(:sensor_id, message)
    end
  end
end
