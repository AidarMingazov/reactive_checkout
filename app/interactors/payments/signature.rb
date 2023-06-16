module Payments
  class Signature
    include Interactor

    delegate :payment, to: :context

    # algorithm check signature
    # values = [token, payment_type, status, extraReturnParam, orderNumber, amount, currency, gatewayAmount, gatewayCurrency]
    # 1) The sum of all parameters, which consists of the length of the string + the string itself.
    # 2) We encode the final string + merchant token in hashlib.md5

    # TODO: in the current implementation, the algorithm does not work correctly

    def call
      # Digest::MD5.hexdigest(prepared_string) == payment.signature
    end

    private

    def token
      payment.processing_url[/token=(.*?)\u0026/m, 1]
    end

    def gateway_amount
      payment.processing_url[/gatewayAmount=(.*?)\u0026/m, 1]
    end

    def gateway_currency
      payment.processing_url[/gatewayCurrency=(.*?)\u0026/m, 1]
    end

    def prepared_string
      values = [
        token,
        'payment',
        payment.status,
        "id_#{payment.id.to_s}",
        "id_#{payment.id.to_s}",
        (payment.price.cents / 100),
        payment.price.currency.iso_code,
        gateway_amount,
        gateway_currency
      ]

      str = ''
      values.each do |e|
        str += e.size.to_s
        str += e
      end

      str + ENV.fetch('REACTIVEPAY_TOKEN')
    end
  end
end
