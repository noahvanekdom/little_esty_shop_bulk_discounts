class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  enum status: [:cancelled, 'in progress', :complete]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def merchant_revenue(merchant)
    invoice_items.joins(:item).where('items.merchant_id = ?', merchant.id)
                  .select('invoice_items.*, SUM(invoice_items.quantity * invoice_items.unit_price) AS total_revenue')
                  .group('invoice_items.id').sum(&:total_revenue)
  end


  def merchant_discount(merchant)
    invoice_items.joins(:bulk_discounts, :item)
                  .where('invoice_items.quantity >= bulk_discounts.threshold')
                  .where('items.merchant_id = ?', merchant.id)
                  .select('invoice_items.item_id, MAX(invoice_items.quantity * invoice_items.unit_price * bulk_discounts.discount_percent * 0.01)')
                  .group('invoice_items.item_id').sum(&:max)
  end

  def merchant_discounted_revenue(merchant)
    merchant_revenue(merchant) - merchant_discount(merchant)
  end

  def invoice_discount
    invoice_items.joins(:bulk_discounts, :item)
                  .where('invoice_items.quantity >= bulk_discounts.threshold')
                  .select('invoice_items.item_id, MAX(invoice_items.quantity * invoice_items.unit_price * bulk_discounts.discount_percent * 0.01)')
                  .group('invoice_items.item_id').sum(&:max)
  end

  def invoice_discounted_revenue
    total_revenue - invoice_discount
  end
end
