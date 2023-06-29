class Add3dsFormToPayments < ActiveRecord::Migration[7.1]
  def change
    add_column :payments, :approve_form, :text
  end
end
