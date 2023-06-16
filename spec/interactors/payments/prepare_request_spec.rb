require 'rails_helper'

describe Payments::PrepareRequest do
  include_context :interactor

  let(:initial_context) { { payment_params: payment_params, user: user, product: product, payment: payment } }
  let(:user) { create :user }
  let(:product) { create :product }
  let(:payment) { create :payment, product: product, user: user }

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

  let(:payment_attributes) do
    {
      'product': product.name,
      'amount': payment.price.cents / 100,
      'currency': payment.price.currency.iso_code,
      'extraReturnParam': "payment_#{payment.id.to_s}",
      'orderNumber': "payment_#{payment.id.to_s}",
      'redirectSuccessUrl': "#{ENV.fetch('CALLBACK_URL')}/api/v1/payments/success/#{payment.id}",
      'redirectFailUrl': "#{ENV.fetch('CALLBACK_URL')}/api/v1/payments/declined/#{payment.id}",
      'callbackUrl': "#{ENV.fetch('CALLBACK_URL')}/api/v1/payments/callback/#{payment.id}"
    }
  end

  let(:customer_attributes) do
    {
      'email': user.email,
      'phone': user.phone,
      'country': user.country,
      'address': user.address,
      'city': user.city,
      'region': user.region,
      'postcode': user.postcode
    }
  end

  let(:card_attributes) do
    {
      'pan': '4392963203551251',
      'expires': '04/2025',
      'holder': 'Test Test',
      'cvv': '213'
    }
  end

  describe '.call' do
    context 'with invalid params' do
      it 'create payments' do
        interactor.run

        expect(context.payment_attributes).to eq payment_attributes
        expect(context.card_attributes).to eq card_attributes
        expect(context.customer_attributes).to eq customer_attributes
      end

      it_behaves_like :success_interactor
    end

    context 'with invalid card' do
      let(:payment_params) do
        {
          'card_cvc' => '213',
          'card_holder' => 'Test Test',
          'card_expared_year' => '2025',
          'card_expared_month' => '4',
          'user_id' => user.id,
          'product_id' => product.id
        }
      end
      let(:error_message) { 'card invalid' }

      it_behaves_like :failed_interactor

      it 'update payment status' do
        interactor.run
        expect(context.payment.status).to eq 'card_invalid'
      end
    end
  end
end
