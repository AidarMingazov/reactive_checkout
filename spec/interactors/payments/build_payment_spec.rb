require 'rails_helper'

describe Payments::BuildPayment do
  include_context :interactor

  let(:initial_context) { { payment_params: payment_params } }
  let(:user) { create :user }
  let(:product) { create :product }

  let(:payment_params) do
    {
      'card_number' => '4392963203551251',
      'card_cvc' => '213',
      'card_holder' => 'Test Test',
      'card_expared_year' => '2025',
      'card_expared_month' => '4',
      'product_id' => product.id,
      'user_id' => user.id
    }
  end

  describe '.call' do
    context 'with invalid params' do
      it 'create payments' do
        interactor.run

        expect { interactor.run }.to change(Payment, :count).by(1)
        expect(context.user).to eq user
        expect(context.product).to eq product
      end

      it_behaves_like :success_interactor
    end

    context 'with invalid product id' do
      let(:payment_params) do
        {
          'card_number' => '4392963203551251',
          'card_cvc' => '213',
          'card_holder' => 'Test Test',
          'card_expared_year' => '2025',
          'card_expared_month' => '4',
          'user_id' => user.id,
          'product_id' => product.id + 1
        }
      end
      let(:error_message) { 'product not found' }

      it_behaves_like :failed_interactor
    end

    context 'with invalid user id' do
      let(:payment_params) do
        {
          'card_number' => '4392963203551251',
          'card_cvc' => '213',
          'card_holder' => 'Test Test',
          'card_expared_year' => '2025',
          'card_expared_month' => '4',
          'user_id' => user.id + 1,
          'product_id' => product.id
        }
      end
      let(:error_message) { 'user not found' }

      it_behaves_like :failed_interactor
    end
  end
end
