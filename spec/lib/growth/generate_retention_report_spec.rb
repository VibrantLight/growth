require 'rails_helper'
require 'growth/generate_retention_report'

RSpec.describe Growth::GenerateRetentionReport do
  describe '#call' do
    it 'generates retention data' do
      create(:customer)
      create_list(:customer_with_order, 5)

      customer =  create(:customer)
      create(:order, created_at: Date.current.beginning_of_month + 7.days, customer: customer)
      create(:order, created_at: Date.current.beginning_of_month + 20.days, customer: customer)
      create(:order, created_at: Date.current.end_of_month, customer: customer)

      expected_result = {
        source_resource: Customer,
        target_resource: Order,
        total_associated_resources: 6,
        total_target_resources: 8,
        resources_stats: [
          {
              total_source_resources_percentage: 83.33,
              total_source_resources: 5,
              total_target_resources: 1,
              first_seven_days_count: 5,
              middle_period_count: 0,
              end_period_count: 0
          },
          {
              total_source_resources_percentage: 16.67,
              total_source_resources: 1,
              total_target_resources: 3,
              first_seven_days_count: 1,
              middle_period_count: 1,
              end_period_count: 1
          }
        ]
      }

      subject.call(associations: 'Customer-Order') do |m|
        m.success do |result|
          expect(result[:report]).to eql(expected_result)
        end
        m.failure {}
      end
    end

    context 'when blank data given' do
      it 'returns empty array' do
        expected_result = {resources_stats: []}

        subject.call(associations: nil) do |m|
          m.success {}
          m.failure {|result| expect(result[:report]).to eql(expected_result)}
        end

        subject.call(associations: '') do |m|
          m.success {}
          m.failure {|result| expect(result[:report]).to eql(expected_result)}
        end
      end
    end

    context 'when invalid associations' do
      it 'returns empty array' do
        expected_result = {resources_stats: []}

        subject.call(associations: 'test') do |m|
          m.success {}
          m.failure {|result| expect(result[:report]).to eql(expected_result)}
        end

        subject.call(associations: '') do |m|
          m.success {}
          m.failure {|result| expect(result[:report]).to eql(expected_result)}
        end
      end
    end
  end
end