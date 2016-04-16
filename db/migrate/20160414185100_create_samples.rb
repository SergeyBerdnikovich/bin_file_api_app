class CreateSamples < ActiveRecord::Migration[5.0]
  def change
    create_table :samples do |t|
      t.integer :sensor_id
      t.integer :light
      t.integer :soil_moisture
      t.integer :air_temperature
      t.datetime :capture_time
    end

    add_index :samples, [:sensor_id, :capture_time]
  end
end
