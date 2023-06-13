class UpdateUsersAccountInfo < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :string, null: false, default: 'customer'
    add_column :users, :phone, :string
    add_column :users, :country, :string
    add_column :users, :address, :string
    add_column :users, :city, :string
    add_column :users, :region, :string
    add_column :users, :postcode, :string
  end
end
