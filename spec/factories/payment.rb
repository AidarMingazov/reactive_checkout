FactoryBot.define do
  factory :payment do
    user_id { create(:user).id }
    product_id { create(:product, price: 100_000).id }
    price { 100_000 }
  end
end
