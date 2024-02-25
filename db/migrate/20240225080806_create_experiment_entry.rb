class CreateExperimentEntry < ActiveRecord::Migration[7.1]
  def change
    create_table :experiment_entries do |t|
      t.string :device_token
      t.string :experiment_key
      t.string :assigned_value

      t.timestamps
    end
  end
end
