require 'csv'

class Product < ApplicationRecord
  validates :name, presence: true
  validates :category, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Adjusted scopes for case-insensitive searches
  scope :by_name, ->(name) { where('lower(name) LIKE ?', "%#{name.downcase}%") if name.present? }
  scope :by_category, ->(category) { where('lower(category) LIKE ?', "%#{category.downcase}%") if category.present? }
  scope :by_availability, ->(available) { where(available: available) if available.present? }
  scope :ordered_by_price, -> { where(available: true).order(price: :asc) }
  scope :ordered_by_quantity, -> { where(available: true).order(quantity: :asc) }

  def self.import(file)
    # Read the file contents directly, handling both StringIO and file objects
    csv_data = file.is_a?(StringIO) ? file.string : File.read(file.path)
  
    CSV.parse(csv_data, headers: true) do |row|
      product_hash = row.to_hash
      begin
        Product.create!(product_hash)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Error importing product: #{e.message}"
      end
    end
  end
end