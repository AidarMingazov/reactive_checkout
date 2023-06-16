FactoryBot.define do
  factory :payout do
    user_id { create(:user).id }
    amount { 100_000 }
  end
end
