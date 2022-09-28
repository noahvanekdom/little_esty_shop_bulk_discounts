require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many(:bulk_discounts).through(:merchants) }
    it { should have_many :transactions }
  end
  describe "instance methods" do
    it "total_revenue" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)

      expect(@invoice_1.total_revenue).to eq(100)
    end

    describe "#discounted_revenue" do
      before(:each) do
        @merchant_1 = Merchant.create!(name: 'Hair Care')
        @merchant_2 = Merchant.create!(name: 'Sporty Spice')

        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant_1.id, status: 1)
        @item_2 = Item.create!(name: "Hair Tie", description: "Too cool for school", unit_price: 2, merchant_id: @merchant_1.id)
        @item_3 = Item.create!(name: "Dye", description: "Colors", unit_price: 50, merchant_id: @merchant_1.id)
        @item_4 = Item.create!(name: "Football", description: "Ball for foot", unit_price: 15, merchant_id: @merchant_2.id)
        @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant_1.id)

        @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @customer_2 = Customer.create!(first_name: 'Mark', last_name: 'Johnson')
        @customer_3 = Customer.create!(first_name: 'Sam', last_name: 'Cal')
        @customer_4 = Customer.create!(first_name: 'Mitch', last_name: 'Black')

        @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
        @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-29 14:54:09")
        @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2, created_at: "2012-03-20 14:54:09")
        @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2, created_at: "2012-03-30 14:54:09")


        @invoice_item_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 19, unit_price: 10, status: 2)
        @invoice_item_2 =  InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_2.id, quantity: 20, unit_price: 15, status: 2)
        @invoice_item_3 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_3.id, quantity: 1, unit_price: 10, status: 1)
        invoice_item_4 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_3.id, quantity: 100, unit_price: 50, status: 2)
        @invoice_item_4 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 22, unit_price: 10, status: 1)


        @bulk_discount_1 = @merchant_1.bulk_discounts.create!(discount_percent: 20, threshold: 10)
        @bulk_discount_2 = @merchant_1.bulk_discounts.create!(discount_percent: 10, threshold: 5)
      end

      it "returns the revenue from an invoice after discounts (if they apply)" do
        expect(@invoice_1.discounted_revenue).to eq(82.0)
        expect(@invoice_2.discounted_revenue).to eq(60.0)
        expect(@invoice_3.discounted_revenue).to eq(0.0)
      end
    end
  end
end
