class Payment < ApplicationRecord
  extend Enumerize

  AVAILABLE_STATUSES = %w[build init approved declined card_invalid bad_response unexpected_result].freeze

  belongs_to :product
  belongs_to :user

  enumerize :status, in: AVAILABLE_STATUSES

  validates :price, numericality: { greater_than: 0, less_than: 1_000_000 }
  composed_of :price, class_name: 'Money', mapping: %w(price cents), converter: Proc.new { |value| Money.new(value) }
end
