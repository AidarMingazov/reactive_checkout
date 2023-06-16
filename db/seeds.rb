Product.find_or_create_by!(name: 'airpods', price: 200_00)
Product.find_or_create_by!(name: 'iphone', price: 1000_00)
Product.find_or_create_by!(name: 'macbook', price: 2500_00)

User.create(
  email: 'customer@test.test',
  password: 'customer',
  password_confirmation: 'customer',
  phone: '99894511',
  country: 'CA',
  address: '4057 Tanner Street',
  city: 'Vancouver',
  region: 'British Columbia',
  postcode: 'V5R 2T4'
)

User.create(
  email: 'admin@test.test',
  role: 'admin',
  password: 'admin123',
  password_confirmation: 'admin123',
  phone: '99894511',
  country: 'CA',
  address: '4057 Tanner Street',
  city: 'Vancouver',
  region: 'British Columbia',
  postcode: 'V5R 2T4'
)
