class Product < ApplicationRecord
  validates :price, presence: true, numericality: { greater_than: 0, less_than: 1_000_000 }

  composed_of :price, class_name: 'Money', mapping: %w(price cents), converter: Proc.new { |value| Money.new(value) }
end
