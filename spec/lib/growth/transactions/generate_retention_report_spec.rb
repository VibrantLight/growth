require 'rails_helper'
require 'growth/transactions/generate_retention_report'

RSpec.describe Growth::Transactions::GenerateRetentionReport do
  describe '#call' do
    it 'generates retention data' do
      create(:product)

      shoes = create(:product_with_line_item)
      shirt = create(:product_with_line_item)
      pants = create(:product_with_line_item)
      hat = create(:product_with_line_item)
      glasses = create(:product_with_line_item)

      chair = create(:product)
      create(:line_item, created_at: Date.current.beginning_of_month + 7.days, product: chair)
      create(:line_item, created_at: Date.current.beginning_of_month + 20.days, product: chair)
      create(:line_item, created_at: Date.current.end_of_month, product: chair)

      expected_result = {
        source_resource: Product,
        target_resource: LineItem,
        total_associated_resources: 6,
        total_target_resources: 8,
        resources_stats: [
          {
              total_source_resources_percentage: 83.33,
              total_source_resources: 5,
              total_target_resources: 1,
              total_source_resources_ids: [shoes.id, shirt.id, pants.id, hat.id, glasses.id]
          },
          {
              total_source_resources_percentage: 16.67,
              total_source_resources: 1,
              total_target_resources: 3,
              total_source_resources_ids: [chair.id]
          }
        ]
      }

      subject.call(associations: 'Product-LineItem') do |m|
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