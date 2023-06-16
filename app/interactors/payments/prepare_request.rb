module Payments
  class PrepareRequest
    include Interactor

    delegate :payment_params, :user, :product, :payment, to: :context

    def call
      unless card_valid
        payment.update(status: 'card_invalid')
        context.fail!(error: 'card invalid')
      end

      context.payment_attributes = payment_attributes
      context.card_attributes = card_attributes
      context.customer_attributes = customer_attributes
    end

    private

    def payment_attributes
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

    def customer_attributes
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

    def card_attributes
      {
        'pan': card_number,
        'expires': expires,
        'holder': card_holder,
        'cvv': card_cvc
      }
    end

    def card_valid
      return false if card_number.blank? || card_expared_month.blank? || card_expared_year.blank? || card_holder.blank? || card_cvc.blank?
      true
    end

    def expires
      month = card_expared_month.size == 1 ? '0' + card_expared_month : card_expared_month

      "#{month}/#{card_expared_year}"
    end

    def card_number
      @card_number ||= payment_params['card_number']
    end

    def card_expared_month
      @card_expared_month ||= payment_params['card_expared_month']
    end

    def card_expared_year
      @card_expared_year ||= payment_params['card_expared_year']
    end

    def card_holder
      @card_holder ||= payment_params['card_holder']
    end

    def card_cvc
      @card_cvc ||= payment_params['card_cvc']
    end
  end
end
