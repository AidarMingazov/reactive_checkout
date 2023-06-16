class CreatePayment < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.integer :price
      t.string :status
      t.string :processing_url
      t.string :signature
      t.json :payment_response

      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
