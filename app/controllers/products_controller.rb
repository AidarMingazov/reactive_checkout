class ProductsController < ApplicationController
  expose :products, -> { Product.all }

  def index
  end
end
