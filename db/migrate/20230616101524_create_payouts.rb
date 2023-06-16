class CreatePayouts < ActiveRecord::Migration[7.1]
  def change
    create_table :payouts do |t|
      t.integer :amount, null: false
      t.string :status
      t.json :payout_response

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
