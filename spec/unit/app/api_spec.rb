require_relative '../../../app/api'
require 'rack/test'

module ExpenseTracker

  DateResults = Struct.new(:success?, :json_response, :error_message)

  RSpec.describe API do
    include Rack::Test::Methods

    def app
      API.new(ledger: ledger)
    end

    def parsed_response
      JSON.parse(last_response.body)
    end

    let(:ledger) { instance_double('ExpenseTracker::Ledger') }

    describe 'POST /expenses' do
      context 'when the expense is successfully recorded' do
        let(:expense){ { 'some' => 'data' } }
        before do
          allow(ledger).to receive(:record).with(expense).and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          expense = { 'some' => 'data' }
          post '/expenses', JSON.generate(expense)
          expect(parsed_response).to include('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          expense = { 'some' => 'data' }
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        let(:expense) { { 'some' => 'data' } }
        before do
          allow(ledger).to receive(:record).with(expense).and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)
          expect(parsed_response).to include('error' => 'Expense incomplete')
        end
        it 'responds with a 422 (Unprocessable entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end

    describe 'GET/expenses/:date' do
      context 'when expenses exist on the given date' do
        let(:date) { 'some-date' }
        before do
          allow(ledger).to receive(:expenses_on).with(date).and_return(['expense_1', 'expense_2'])
        end

        it 'returns the expense records as JSON' do
          get "/expenses/#{date}"
          expect(parsed_response).to eq(['expense_1', 'expense_2'])
        end

        it 'responds with a 200 (OK)' do
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        let(:date) { 'some-date' }
        before do
          allow(ledger).to receive(:expenses_on).with(date).and_return(DateResults.new(true, {}, nil))
        end

        it 'returns an empty array as JSON' do
          allow(ledger).to receive(:expenses_on).with(date).and_return(DateResults.new(true, '417', nil))
          get "/expenses/#{date}"
          expect(parsed_response).to eq([])
        end

        it 'responds with a 200 (OK)' do
          allow(ledger).to receive(:expenses_on).with(date).and_return(DateResults.new(true, '417', nil))
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end

    end
  end
end
