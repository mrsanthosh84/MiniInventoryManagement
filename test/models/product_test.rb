require "test_helper"
require "csv"
require "stringio"  # Ensure StringIO is required for the CSV test

class ProductTest < ActiveSupport::TestCase
  def setup
    Product.delete_all # Clean the database before each test

    @valid_attributes = {
      name: "Test Product",
      category: "Test Category",
      quantity: 10,
      price: 20.00,
      available: true
    }

    @product = Product.create!(@valid_attributes)
    @unavailable_product = Product.create!(name: "Unavailable Product", category: "Category B", quantity: 5, price: 15.00, available: false)
    @another_product = Product.create!(name: "Another Product", category: "Category A", quantity: 8, price: 25.00, available: true)
  end

  # Validation Tests
  test "should not save product without name" do
    product = Product.new(@valid_attributes.except(:name))
    assert_not product.save, "Saved the product without a name"
  end

  test "should not save product without category" do
    product = Product.new(@valid_attributes.except(:category))
    assert_not product.save, "Saved the product without a category"
  end

  test "should not save product without price" do
    product = Product.new(@valid_attributes.except(:price))
    assert_not product.save, "Saved the product without a price"
  end

  test "should not save product with negative price" do
    product = Product.new(@valid_attributes.merge(price: -1))
    assert_not product.save, "Saved the product with a negative price"
  end

  test "should save product with valid attributes" do
    product = Product.new(@valid_attributes)
    assert product.save, "Failed to save the product with valid attributes"
  end

  # Scope Tests
  test "should return only available products by availability scope" do
    available_products = Product.by_availability(true)
    assert_includes available_products, @product
    assert_includes available_products, @another_product
    assert_not_includes available_products, @unavailable_product
  end

  test "should return products filtered by name" do
    products = Product.by_name("Test")
    assert_includes products, @product
    assert_not_includes products, @unavailable_product
  end

  test "should return products filtered by category" do
    products = Product.by_category("Category B")
    assert_includes products, @unavailable_product
    assert_not_includes products, @product
  end

  test "should order products by price" do
    ordered_products = Product.ordered_by_price
    assert_equal [@product, @another_product], ordered_products.to_a
  end


  test "should import products from CSV" do
    csv_content = <<~CSV
      name,category,quantity,price,available
      Product 1,Category 1,10,15.00,true
      Product 2,Category 2,5,10.00,false
    CSV

    file = StringIO.new(csv_content)
    Product.import(file)

    assert_equal 5, Product.count # 2 from CSV + 3 from setup
    assert Product.exists?(name: "Product 1")
    assert Product.exists?(name: "Product 2")
  end

  test "should log error for invalid product during import" do
    csv_content = <<~CSV
      name,category,quantity,price,available
      ,Category 1,10,15.00,true
    CSV

    file = StringIO.new(csv_content)

    assert_no_difference 'Product.count' do
      Product.import(file)
    end
  end
end
