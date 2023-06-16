class PaymentsController < ApplicationController
  expose :payments, :fetch_payments
  expose :payment, :fetch_payment
  expose :product, :fetch_product

  def show; end

  def new; end

  def create
    result = Payments::Create.call(payment_params: payment_params)

    if result.success?
      redirect_to payment_path(result.payment)
    else
      flash[:error] = result.error
      redirect_to root_path
    end
  end

  private

  def fetch_payments
    current_user.payments
  end

  def fetch_payment
    Payment.find_by(id: params[:id])
  end

  def fetch_product
    Product.find_by(id: params[:product_id])
  end

  def payment_params
    params.require(:payment).permit(
      :card_number, :card_cvc, :card_holder,
      :card_expared_year, :card_expared_month, :product_id
    ).merge!(user_id: current_user.id)
  end
end
