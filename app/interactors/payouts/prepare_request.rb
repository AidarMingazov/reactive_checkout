module Payouts
  class PrepareRequest
    include Interactor

    delegate :payout_params, :user, :payout, to: :context

    def call
      unless card_valid
        payout.update(status: 'card_invalid')
        context.fail!(error: 'card invalid')
      end

      context.payout_attributes = payout_attributes
      context.card_attributes = card_attributes
      context.customer_attributes = customer_attributes
    end

    private

    def payout_attributes
      {
        'amount': payout.amount.cents / 100,
        'currency': payout.amount.currency.iso_code,
        'extraReturnParam': "payout_#{payout.id.to_s}",
        'orderNumber': "payout_#{payout.id.to_s}"
      }
    end

    def customer_attributes
      {
        'email': user.email,
        'address': user.address,
        'ip': user.last_sign_in_ip
      }
    end

    def card_attributes
      {
        'pan': card_number,
        'expires': expires
      }
    end

    def card_valid
      return false if card_number.blank? || card_expared_month.blank? || card_expared_year.blank?
      true
    end

    def expires
      month = card_expared_month.size == 1 ? '0' + card_expared_month : card_expared_month

      "#{month}/#{card_expared_year}"
    end

    def card_number
      @card_number ||= payout_params['card_number']
    end

    def card_expared_month
      @card_expared_month ||= payout_params['card_expared_month']
    end

    def card_expared_year
      @card_expared_year ||= payout_params['card_expared_year']
    end
  end
end
