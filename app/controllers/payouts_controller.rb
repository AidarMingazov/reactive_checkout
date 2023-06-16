class PayoutsController < ApplicationController
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :policy

  expose :payouts, :fetch_payouts
  expose :payout, :fetch_payout

  def index; end

  def show; end

  def new; end

  def create
    result = Payouts::Create.call(payout_params: payout_params)

    redirect_to payout_path(result.payout)
  end

  private

  def fetch_payouts
    current_user.payouts
  end

  def fetch_payout
    Payout.find_by(id: params[:id])
  end

  def payout_params
    params.require(:payout).permit(
      :card_number, :card_expared_year, :card_expared_month, :amount
    ).merge!(user_id: current_user.id)
  end

  def policy
    raise Pundit::NotAuthorizedError unless PayoutPolicy.new(current_user).access?
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to root_path
  end
end
