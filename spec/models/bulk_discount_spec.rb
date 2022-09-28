require 'rails_helper'

describe BulkDiscount do
  describe "validations" do
    it { should validate_presence_of :threshold }
    it { should validate_presence_of :discount_percent }
  end
  describe "relationships" do
    it { should belong_to :merchant }
    it { should have_many(:items).through(:merchant)}
    it { should have_many(:invoice_items).through(:items)}
    it { should have_many(:invoices).through(:invoice_items)}
  end
end