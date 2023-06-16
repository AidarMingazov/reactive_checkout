require 'rails_helper'

describe Payouts::BuildPayout do
  include_context :interactor

  let(:initial_context) { { payout_params: payout_params } }
  let(:user) { create :user, role: 'admin', last_sign_in_ip: '1.1.1.1' }
  let(:product) { create :product }

  let(:payout_params) do
    {
      'card_number' => '4392963203551251',
      'card_expared_year' => '2025',
      'card_expared_month' => '4',
      'amount' => 10000,
      'user_id' => user.id
    }
  end

  describe '.call' do
    context 'with invalid params' do
      it 'create payout' do
        interactor.run

        expect { interactor.run }.to change(Payout, :count).by(1)
        expect(context.user).to eq user
      end

      it_behaves_like :success_interactor
    end

    context 'with invalid user id' do
      let(:user) { create :user, role: 'customer' }

      let(:payout_params) do
        {
          'card_number' => '4392963203551251',
          'card_expared_year' => '2025',
          'card_expared_month' => '4',
          'amount' => 10000,
          'user_id' => user.id + 1,
          'ip' => '1.1.1.1'
        }
      end
      let(:error_message) { 'admin not found' }

      it_behaves_like :failed_interactor
    end
  end
end
