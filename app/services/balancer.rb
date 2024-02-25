module Balancer
  def self.arrange!(current_percentages, initial_percentages)
    total_count = current_percentages.values.sum
    desired_counts = initial_percentages.transform_values { |percentage| (total_count * percentage / 100.0).floor }

    differences = desired_counts.map { |key, value| [key, value - current_percentages.fetch(key, 0)] }.to_h

    key_to_assign = differences.max_by { |_key, value| value }.first

    key_to_assign
  end
end
