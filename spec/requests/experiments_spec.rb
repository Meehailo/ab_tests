require 'rails_helper'

RSpec.describe "Experiments", type: :request do
  describe "GET /experiments" do

    it "returns a list of experiments with their distribution" do
      get '/experiments'

      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq("application/json; charset=utf-8")

      json_response = JSON.parse(response.body)
      expect(json_response).to be_a(Hash)
    end
  end

  describe "GET /experiments with the same Device-Token" do
    let(:device_token) { "unique_token_123" }
    let(:headers) { { "Device-Token" => device_token } }

    it "returns the same experiment for the same Device-Token" do
      get '/experiments', headers: headers
      expect(response).to have_http_status(:success)
      first_response = JSON.parse(response.body)

      get '/experiments', headers: headers
      expect(response).to have_http_status(:success)
      second_response = JSON.parse(response.body)

      first_response.transform_values! { |v| v.to_s }
      second_response.transform_values! { |v| v.to_s }

      expect(first_response).to eq(second_response)
    end
  end

  describe "Distribution of experiments" do
    let(:experiments) { YAML.load(File.open(Rails.root.join('lib', 'experiments', 'experiments.yml'))) }
    let(:number_of_requests) { 1000 }
    let(:distribution_tolerance) { 10 }

    it "approximates to the defined probabilities" do
      results = {}

      experiments.each do |experiment_key, options|
        results[experiment_key] = Hash.new(0)
      end

      number_of_requests.times do |i|
        get '/experiments', headers: { "Device-Token" => "token_#{i}" }
        JSON.parse(response.body).each do |key, value|
          results[key][value] += 1
        end
      end

      experiments.each do |experiment_key, options|
        total_responses = results[experiment_key].values.sum
        options.each do |value, expected_percentage|
          observed_count = results[experiment_key][value]
          observed_percentage = (observed_count.to_f / total_responses) * 100

          expected_lower_bound = expected_percentage - distribution_tolerance
          expected_upper_bound = expected_percentage + distribution_tolerance

          expect(observed_percentage).to be_within(distribution_tolerance).of(expected_percentage), "Expected #{experiment_key} to be within #{expected_lower_bound}% - #{expected_upper_bound}%, but got #{observed_percentage}%"
        end
      end
    end
  end
end
