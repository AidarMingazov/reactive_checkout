module Payments
  class SendCreateRequest
    include Interactor

    delegate :payment_attributes, :card_attributes, :customer_attributes, :payment, to: :context

    def call
      if create_payment_response.success?
        if approved?
          update_payment('approved')
        elsif init?
          update_payment('init')
          context.redirect_request = redirect_request
        else
          payment.update(status: 'unexpected_result', payment_response: parsed_response)
          context.fail!(error: 'unexpected result')
        end
      else
        payment.update(status: 'bad_response', payment_response: parsed_response)
        context.fail!(error: parsed_response['errors'])
      end
    end

    private

    def create_payment_response
      @create_payment_response ||= Reactivepay::Client.new.create_payment(payment_attributes, card_attributes, customer_attributes)
    end

    def parsed_response
      @parsed_response ||= JSON.parse(create_payment_response.body)
    end

    def update_payment(status)
      payment.update(
        status: status,
        payment_response: parsed_response
      )
    end

    def approved?
      parsed_response['payment']['status'] == 'approved'
    end

    def init?
      parsed_response['payment']['status'] == 'init'
    end

    def redirect_request
      parsed_response['redirectRequest']
    end
  end
end
