require 'rails_helper'

describe Payouts::SendCreateRequest do
  include_context :interactor

  let(:initial_context) do
    {
      payout_attributes: payout_attributes,
      card_attributes: card_attributes,
      customer_attributes: customer_attributes,
      payout: payout
    }
  end

  let(:user) { create :user, role: 'admin', last_sign_in_ip: '1.1.1.1' }
  let(:payout) { create :payout, user: user, amount: 10000 }

  let(:payout_attributes) do
    {
      'amount': payout.amount.cents / 100,
      'currency': payout.amount.currency.iso_code,
      'extraReturnParam': "id_#{payout.id.to_s}",
      'orderNumber': "id_#{payout.id.to_s}"
    }
  end

  let(:customer_attributes) do
    {
      'email': user.email,
      'address': user.address,
      'ip': '1.1.1.1'
    }
  end

  let(:card_attributes) do
    {
      'pan': '4392963203551251',
      'expires': '04/2025'
    }
  end

  let(:approved_response_body) do
    {
      'success': true,
      'result': 0,
      'status': 200,
      'payout': {
        'amount': 100, 
        'gateway_amount': 100,
        'currency': 'USD',
        'status': 'approved'
      }
    }.to_json
  end

  let(:reactivepay_response) { instance_double(HTTParty::Response, body: approved_response_body, success?: true) }
  let(:reactivepay_client) { instance_double(Reactivepay::Client, create_payout: reactivepay_response) }

  before do
    allow(ENV).to receive(:fetch).with('REACTIVEPAY_BASE_URL').and_return("http://localhost:3000")
    allow(Reactivepay::Client).to receive(:new).and_return(reactivepay_client)
  end

  describe '.call' do
    context 'with valid response' do
      it 'approved payout request' do
        interactor.run
        expect(context.payout.status).to eq 'approved'
        expect(context.payout.payout_response).to eq JSON.parse(approved_response_body)
      end

      it_behaves_like :success_interactor
    end

    context 'invalid response' do
      let(:reactivepay_response) { instance_double(HTTParty::Response, body: response_body, success?: false) }

      let(:response_body) do
        {
          'success': false,
          'result': 1,
          'status': 403,
          'errors': [
            {
              'code': 'amount_less_than_balance',
              'kind': 'processing_error'
            }
          ]
        }.to_json
      end

      let(:error_message) { [{ 'code' => 'amount_less_than_balance', 'kind' => 'processing_error' }] }

      it_behaves_like :failed_interactor
    end
  end
end
