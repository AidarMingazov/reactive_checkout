class AddCallbackToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :callback, :string
    add_column :payments, :token, :string
  end
end
