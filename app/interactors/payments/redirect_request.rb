module Payments
  class RedirectRequest
    include Interactor

    delegate :redirect_request, :payment, to: :context

    def call
      if payment.status == 'init' && redirect_response.success?
        payment.update(approve_form: redirect_response)
      end
    end

    private

    def redirect_response
      @redirect_response ||= Reactivepay::Client.new.redirect_3ds(redirect_url, redirect_params)
    end

    def redirect_url
      redirect_request['url']
    end

    def redirect_params
      redirect_request['params']
    end
  end
end
