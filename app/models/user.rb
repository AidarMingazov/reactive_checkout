class User < ApplicationRecord
  extend Enumerize

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :payments
  has_many :payouts

  enumerize :role, in: %i[customer admin], default: :customer
end
