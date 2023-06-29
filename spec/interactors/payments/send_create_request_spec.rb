require 'rails_helper'

describe Payments::SendCreateRequest do
  include_context :interactor

  let(:initial_context) do
    {
      payment_attributes: payment_attributes,
      card_attributes: card_attributes,
      customer_attributes: customer_attributes,
      payment: payment
    }
  end

  let(:user) { create :user }
  let(:product) { create :product }
  let(:payment) { create :payment, product: product, user: user }

  let(:payment_attributes) do
    {
      'product': product.name,
      'amount': payment.price.cents / 100,
      'currency': payment.price.currency.iso_code,
      'extraReturnParam': "id_#{payment.id.to_s}",
      'orderNumber': "id_#{payment.id.to_s}",
      'redirectSuccessUrl': 'https://reactive-y69rn.ondigitalocean.app/',
      'redirectFailUrl': 'https://reactive-y69rn.ondigitalocean.app/',
      'callbackUrl': 'https://reactive-y69rn.ondigitalocean.app/'
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

  let(:approved_response_body) do
    {
      'success': true,
      'result': 0,
      'status': 200,
      'token': 'token',
      'processingUrl': 'https://reactive-y69rn.ondigitalocean.app/',
      'payment': {
        'amount': 100, 
        'gateway_amount': 100,
        'currency': 'USD',
        'status': 'approved',
        'two_stage_mode': false,
        'commission': 0.0
      }
    }.to_json
  end

  let(:redirect_request) do
    {
      'redirectRequest': {
        'url': 'https://demo.reactivepay.com/demo/3ds',
        'params': {
          'PaReq': 'TEST_PAREQ_SUCCESS',
          'TermUrl': 'https://business.reactivepay.com/checkout_results/TOKEN/callback_3ds',
          'MD': 'SOMEMD'
        },
        'type': 'post'
      }
    }.to_json
  end

  let(:reactivepay_response) { instance_double(HTTParty::Response, body: approved_response_body, success?: true) }
  let(:reactivepay_client) { instance_double(Reactivepay::Client, create_payment: reactivepay_response) }

  before do
    allow(ENV).to receive(:fetch).with('REACTIVEPAY_BASE_URL').and_return("http://localhost:3000")
    allow(Reactivepay::Client).to receive(:new).and_return(reactivepay_client)
  end

  describe '.call' do
    context 'with valid response' do
      it 'approved payments request' do
        interactor.run
        expect(context.payment.status).to eq 'approved'
        expect(context.payment.payment_response).to eq JSON.parse(approved_response_body)
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

    context 'with valid response with redirectRequest' do
      let(:approved_response_body) do
        {
          'success': true,
          'result': 0,
          'status': 200,
          'token': 'token',
          'processingUrl': 'https://reactive-y69rn.ondigitalocean.app/',
          'payment': {
            'amount': 100, 
            'gateway_amount': 100,
            'currency': 'USD',
            'status': 'init',
            'two_stage_mode': false,
            'commission': 0.0
          },
          'redirectRequest': redirect_request
        }.to_json
      end

      it 'init payments request' do
        interactor.run
        expect(context.payment.status).to eq 'init'
        expect(context.payment.payment_response).to eq JSON.parse(approved_response_body)
        expect(context.redirect_request).to eq redirect_request
      end

      it_behaves_like :success_interactor
    end
  end
end
