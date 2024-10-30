class ProductsController < ApplicationController
  def index
    @products = Product.all

    if params[:search].present?
      Rails.logger.debug @products.to_sql
      @products = @products.by_name(params[:search])
      @products = @products.by_category(params[:category])
      @products = @products.by_availability(params[:available]) if params[:available].present?
      @products = params[:sort] == 'quantity' ? @products.ordered_by_quantity : @products.ordered_by_price
    end

    if params[:available].present?
      @products = @products.where(available: params[:available] == 'true')
    end

    if params[:order].present?
      @products = @products.order(params[:order])
    end
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path, notice: 'Product was successfully created.'
    else
      render :new
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to products_path, notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  def import
    if params[:file].present?
      Product.import(params[:file])
      redirect_to products_path, notice: "Products imported successfully."
    else
      redirect_to products_path, alert: "No file selected for import."
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    redirect_to products_path, notice: 'Product was successfully deleted.'
  end

  private

  def product_params
    params.require(:product).permit(:name, :category, :quantity, :price, :available)
  end
end
