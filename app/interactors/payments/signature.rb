module Payments
  class Signature
    include Interactor

    delegate :payment, :callback, to: :context

    # algorithm check signature
    # values = [token, payment_type, status, extraReturnParam, orderNumber, amount, currency, gatewayAmount, gatewayCurrency]
    # 1) The sum of all parameters, which consists of the length of the string + the string itself.
    # 2) We encode the final string + merchant token in hashlib.md5

    def call
      context.fail!(error: 'payment not found') unless payment

      payment.update(callback: callback)
      Digest::MD5.hexdigest(prepared_string) == callback['signature']
    end

    private

    def prepared_string
      values = [
        callback['token'],
        callback['status'],
        callback['extraReturnParam'],
        callback['orderNumber'],
        callback['amount'],
        callback['currency'],
        callback['gatewayAmount'],
        callback['gatewayCurrency']
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
