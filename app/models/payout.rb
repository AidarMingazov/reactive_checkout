class Payout < ApplicationRecord
  extend Enumerize

  AVAILABLE_STATUSES = %w[build approved declined card_invalid].freeze

  belongs_to :user

  enumerize :status, in: AVAILABLE_STATUSES

  validates :amount, numericality: { greater_than: 0 }
  composed_of :amount, class_name: 'Money', mapping: %w(amount cents), converter: Proc.new { |value| Money.new(value) }
end
