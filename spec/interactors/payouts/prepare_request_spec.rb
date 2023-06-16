require 'rails_helper'

describe Payouts::PrepareRequest do
  include_context :interactor

  let(:initial_context) { { payout_params: payout_params, user: user, payout: payout } }
  let(:user) { create :user, role: 'admin', last_sign_in_ip: '1.1.1.1' }
  let(:payout) { create :payout, user: user }

  let(:payout_params) do
    {
      'card_number' => '4392963203551251',
      'card_expared_year' => '2025',
      'card_expared_month' => '4',
      'user_id' => user.id,
      'ip' => '1.1.1.1'
    }
  end

  let(:payout_attributes) do
    {
      'amount': payout.amount.cents / 100,
      'currency': payout.amount.currency.iso_code,
      'extraReturnParam': "payout_#{payout.id.to_s}",
      'orderNumber': "payout_#{payout.id.to_s}"
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

  describe '.call' do
    context 'with invalid params' do
      it 'create payout' do
        interactor.run

        expect(context.payout_attributes).to eq payout_attributes
        expect(context.card_attributes).to eq card_attributes
        expect(context.customer_attributes).to eq customer_attributes
      end

      it_behaves_like :success_interactor
    end

    context 'with invalid card' do
      let(:payout_params) do
        {
          'card_expared_year' => '2025',
          'card_expared_month' => '4',
          'user_id' => user.id
        }
      end
      let(:error_message) { 'card invalid' }

      it_behaves_like :failed_interactor

      it 'update payout status' do
        interactor.run
        expect(context.payout.status).to eq 'card_invalid'
      end
    end
  end
end
