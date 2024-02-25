class StatisticsController < ApplicationController
  EXPERIMENTS_FILE = 'lib/experiments/experiments.yml'.freeze

  def index
    experiments = YAML.load(File.open(EXPERIMENTS_FILE))
    statistics = experiments.keys.each_with_object({}) do |experiment_key, stats|
      entries = ExperimentEntry.where(experiment_key: experiment_key)
      total_count = entries.count
      options_distribution = entries.group(:assigned_value).count

      stats[experiment_key] = {
        total_devices: total_count,
        distribution: options_distribution
      }
    end

    render json: statistics
  end
end
