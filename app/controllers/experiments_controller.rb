class ExperimentsController < ApplicationController
  EXPERIMENTS_FILE = 'lib/experiments/experiments.yml'.freeze

  def index
    device_token = request.headers['Device-Token']
    render json: assign_experiments_for(device_token)
  end

  private

  def assign_experiments_for(device_token)
    experiments = YAML.load(File.open(EXPERIMENTS_FILE))
    assigned_experiments = {}

    experiments.each do |experiment_key, options|
      assigned_value = find_or_assign_experiment(device_token, experiment_key, options)
      assigned_experiments[experiment_key] = assigned_value
    end

    assigned_experiments
  end

  def find_or_assign_experiment(device_token, experiment_key, options)
    entry = ExperimentEntry.find_or_initialize_by(device_token: device_token, experiment_key: experiment_key)
    return entry.assigned_value if entry.persisted?

    initial_percentages = options.transform_values(&:to_f)
    current_percentages = calculate_current_percentages(experiment_key, options.keys)
    assigned_value = Balancer.arrange!(current_percentages, initial_percentages)

    entry.assigned_value = assigned_value
    entry.save!
    assigned_value
  end

  def calculate_current_percentages(experiment_key, option_keys)
    entries = ExperimentEntry.where(experiment_key: experiment_key)
    total_entries = entries.count.to_f

    current_percentages = option_keys.each_with_object({}) do |key, hash|
      option_count = entries.where(assigned_value: key).count.to_f
      hash[key] = total_entries > 0 ? (option_count / total_entries * 100).round(2) : 0
    end
    current_percentages
  end
end
