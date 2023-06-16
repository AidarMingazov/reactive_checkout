FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { '1$Password!2' }
    role { 'customer' }
    phone { '99894511' }
    country { 'CA' }
    address { '4057 Tanner Street' }
    city { 'Vancouver' }
    region { 'British Columbia'}
    postcode { 'V5R 2T4' }
  end
end
