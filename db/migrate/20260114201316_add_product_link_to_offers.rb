class AddProductLinkToOffers < ActiveRecord::Migration[7.2]
  def change
    add_column :offers, :product_link, :string
  end
end
