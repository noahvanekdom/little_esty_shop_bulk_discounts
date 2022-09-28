require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
  end
  describe "relationships" do
    it { should belong_to :invoice }
    it { should belong_to :item }
  end

  describe "class methods" do
    before(:each) do
      @m1 = Merchant.create!(name: 'Merchant 1')
      @m2 = Merchant.create!(name: 'Merchant 2')
      @m3 = Merchant.create!(name: 'Merchant 3')
      @c1 = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')
      @c2 = Customer.create!(first_name: 'Frodo', last_name: 'Baggins')
      @c3 = Customer.create!(first_name: 'Samwise', last_name: 'Gamgee')
      @c4 = Customer.create!(first_name: 'Aragorn', last_name: 'Elessar')
      @c5 = Customer.create!(first_name: 'Arwen', last_name: 'Undomiel')
      @c6 = Customer.create!(first_name: 'Legolas', last_name: 'Greenleaf')
      @item_1 = Item.create!(name: 'Shampoo', description: 'This washes your hair', unit_price: 10, merchant_id: @m1.id)
      @item_2 = Item.create!(name: 'Conditioner', description: 'This makes your hair shiny', unit_price: 8, merchant_id: @m1.id)
      @item_3 = Item.create!(name: 'Brush', description: 'This takes out tangles', unit_price: 5, merchant_id: @m1.id)
      @item_4 = Item.create!(name: 'Sword', description: 'Slishy Slashy', unit_price: 20, merchant_id: @m3.id)
      @i1 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i2 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i3 = Invoice.create!(customer_id: @c2.id, status: 2)
      @i4 = Invoice.create!(customer_id: @c3.id, status: 2)
      @i5 = Invoice.create!(customer_id: @c4.id, status: 2)
      @i6 = Invoice.create!(customer_id: @c5.id, status: 2)
      @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 100, unit_price: 10, status: 0)
      @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
      @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_3.id, quantity: 400, unit_price: 5, status: 2)
      @ii_4 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 1)
      @ii_5 = InvoiceItem.create!(invoice_id: @i6.id, item_id: @item_4.id, quantity: 1, unit_price: 10, status: 2)



      @bulk_discount_1 = @m1.bulk_discounts.create!(discount_percent: 20, threshold: 10)
      @bulk_discount_2 = @m1.bulk_discounts.create!(discount_percent: 10, threshold: 5)
      @bulk_discount_4 = @m1.bulk_discounts.create!(discount_percent: 60, threshold: 500)
      @bulk_discount_3 = @m2.bulk_discounts.create!(discount_percent: 30, threshold: 40)
    end

    it 'incomplete_invoices' do
      expect(InvoiceItem.incomplete_invoices).to eq([@i1, @i3])
    end

    describe "#find_discount" do
      it "returns the relevant discount for an invoice item" do
        expect(@ii_1.find_discount).to eq(@bulk_discount_1)
        expect(@ii_3.find_discount).to eq(@bulk_discount_1)
        expect(@ii_5.find_discount).to eq(nil)
      end
    end
  end
end
