module Payouts
  class SendCreateRequest
    include Interactor

    delegate :payout_attributes, :card_attributes, :customer_attributes, :payout, to: :context

    def call
      if create_payout_response.success?
        payout.update(payout_response: parsed_response, status: 'approved')
      else
        payout.update(payout_response: parsed_response, status: 'declined')
        context.fail!(error: parsed_response['errors'])
      end
    end

    private

    def create_payout_response
      @create_payout_response ||= Reactivepay::Client.new.create_payout(payout_attributes, card_attributes, customer_attributes)
    end

    def parsed_response
      @parsed_response ||= JSON.parse(create_payout_response.body)
    end
  end
end
