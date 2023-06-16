module Payouts
  class BuildPayout
    include Interactor

    delegate :payout_params, to: :context

    def call
      context.fail!(error: 'admin not found') unless user.present? && user.role == 'admin'

      context.payout = create_payout
      context.user = user

      context.fail!(error: 'payout not valid') unless context.payout.valid?
    end

    private

    def create_payout
      Payout.create(user: user, amount: payout_params['amount'], status: 'build')
    end

    def user
      @user ||= User.find_by(id: payout_params['user_id'])
    end
  end
end
