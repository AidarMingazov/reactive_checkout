require "rails_helper"

describe Reactivepay::Client do
  let(:request_headers) do
    {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{ENV.fetch('REACTIVEPAY_TOKEN')}"
    }
  end

  describe '.create_payment' do
    subject(:create_payment) { described_class.new.create_payment(attributes, card, customer) }

    let(:reactivepay_response) { instance_double(HTTParty::Response, body: reactivepay_response_body) }
    let(:reactivepay_response_body) { 'response_body' }
    let(:url) { "#{ENV.fetch('REACTIVEPAY_BASE_URL')}payments" }

    before do
      allow(HTTParty).to receive(:post).and_return(reactivepay_response)
      create_payment
    end

    context 'with some attributes' do
      let(:attributes) do
        {
          'product': 'Product test',
          'amount': 100,
          'currency': 'USD',
          'extraReturnParam': 'test3119',
          'orderNumber': 'test123',
          'redirectSuccessUrl': 'https://test.test',
          'redirectFailUrl': 'https://test.test',
          'callbackUrl': 'https://test.test'
        }
      end

      let(:card) do
        {
          'pan': '4392963203551251',
          'expires': '05/2024',
          'holder': 'Test Test',
          'cvv': '251'
         }
      end

      let(:customer) do
        {
          'email': 'test@test.test',
          'phone': '99894511',
          'country': 'CA',
          'address': '4057 Tanner Street',
          'city': 'Vancouver',
          'region': 'British Columbia',
          'postcode': 'V5R 2T4'
         }
      end

      let(:request_body) do
        attributes.merge!(card: card).merge!(customer: customer).to_json
      end

      it 'makes post request to payments endpoint' do
        expect(HTTParty).to have_received(:post).with(url, body: request_body, headers: request_headers)
      end
    end
  end
end
