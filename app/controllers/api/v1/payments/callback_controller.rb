class Api::V1::Payments::CallbackController < ActionController::API
  expose :payment, :fetch_payment

  def declined
    payment.update(callback: params, status: 'declined')

    render json: {}, status: :ok
  end

  def success
    Payments::Signature.call(payment: payment, callback: params)

    render json: {}, status: :ok
  end

  def callback
    Payments::Signature.call(payment: payment, callback: params)

    render json: {}, status: :ok
  end

  private

  def fetch_payment
    Payment.find_by(id: params[:id])
  end
end
