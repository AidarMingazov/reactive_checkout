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
      'processingUrl': processing_url,
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

  let(:processing_url) do
    "https://reactive-y69rn.ondigitalocean.app/?token=3n9vrwbwsiWp6kV88KdoN2z19K7aQr12\u0026type=pay\u0026status=approved\u0026"\
    "extraReturnParam=test3119\u0026orderNumber=test123\u0026walletDisplayName=\u0026amount=100\u0026currency=USD\u0026"\
    "gatewayAmount=100\u0026gatewayCurrency=USD\u0026gatewayDetails=%7B%22merchant%22%3D%3E%7B%22ip%22%3D%3E%2294.25.171.232%22%7D%2C+%22"\
    "processing_url%22%3D%3E%22https%3A%2F%2Fbusiness.reactivepay.com%2Fcheckout%2F3n9vrwbwsiWp6kV88KdoN2z19K7aQr12%3Fcustomer%255Baddress"\
    "%255D%3D4057%2BTanner%2BStreet%26customer%255Bcity%255D%3DVancouver%26customer%255Bcountry%255D%3DCA%26customer%255Bemail%255D%3Dtest"\
    "%2540test.test%26customer%255Bphone%255D%3D99894511%26customer%255Bpostcode%255D%3DV5R%2B2T4%26customer%255Bregion%255D%3DBritish%2BColumbia"\
    "%22%7D\u0026cardHolder=Reactivepay+Test\u0026sanitizedMask=439296******1251\u0026walletToken=7944008c4ef240e2fc5f06eac5e74f687b4c\u0026"\
    "signature=4e3493f4d67a20487d96d2de83f03ee2"
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
        expect(context.payment.signature).to eq '4e3493f4d67a20487d96d2de83f03ee2'
        expect(context.payment.payment_response).to eq JSON.parse(approved_response_body)
        expect(context.payment.processing_url).to eq processing_url
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
