require 'rails_helper'

RSpec.feature "Products Management", type: :feature do
  before do
    # Create sample products for testing
    @product_a = Product.create!(name: "Product A", category: "Category 1", quantity: 5, price: 9.99, available: true)
    @product_b = Product.create!(name: "Product B", category: "Category 2", quantity: 2, price: 19.99, available: false)
    @product_c = Product.create!(name: "Product C", category: "Category 1", quantity: 8, price: 15.00, available: true)
  end

  scenario "User visits the products index" do
    visit products_path
    expect(page).to have_content("Product Inventory")
    expect(page).to have_content(@product_a.name)
    expect(page).to have_content(@product_b.name)
    expect(page).to have_content(@product_c.name)
  end

  scenario "User can filter products by name" do
    visit products_path
    fill_in "search", with: "Product A"
    click_on "Search"
    expect(page).to have_content("Product A")
    expect(page).not_to have_content("Product B")
    expect(page).not_to have_content("Product C")
  end

  scenario "User can filter products by availability" do
    visit products_path
    select 'Yes', from: 'available'
    click_on "Filter"
    expect(page).to have_content("Product A")
    expect(page).to have_content("Product C")
    expect(page).not_to have_content("Product B")
  end

  scenario "User can sort products by price" do
    visit products_path
    select 'Price', from: 'order'  
    click_on "Sort"
    expect(page).to have_content("Product A")
  end

  scenario "User can edit a product" do
    product = Product.create(name: "Product A", category: "Category", quantity: 10, price: 15.00, available: true)
  
    visit edit_product_path(product)
    fill_in "Name", with: "Updated Product A"
    fill_in "Category", with: "Updated Category"
    fill_in "Quantity", with: 20
    fill_in "Price", with: 25.00
    check "Available"
    click_on "Save"
  
    expect(page).to have_content("Product was successfully updated.")
  end

  scenario "User can delete a product" do
    visit products_path
    accept_confirm do
      click_on "Delete", match: :first  # Delete the first product
    end

    expect(page).to have_content("Product was successfully deleted.")
  end
end
