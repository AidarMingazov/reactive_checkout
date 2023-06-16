class PayoutPolicy
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def access?
    user.role == 'admin'
  end
end
