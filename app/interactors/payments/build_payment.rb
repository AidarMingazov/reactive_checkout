module Payments
  class BuildPayment
    include Interactor

    delegate :payment_params, to: :context

    def call
      context.fail!(error: 'product not found') unless product
      context.fail!(error: 'user not found') unless user

      context.payment = create_payment
      context.user = user
      context.product = product
    end

    private

    def create_payment
      Payment.create(
        product: product,
        user: user,
        price: product.price,
        status: 'build'
      )
    end

    def product
      @product ||= Product.find_by(id: payment_params['product_id'])
    end

    def user
      @user ||= User.find_by(id: payment_params['user_id'])
    end
  end
end
