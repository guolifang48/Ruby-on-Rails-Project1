class Admin::OrderNotesController < ApplicationController
  before_action :set_order
  before_action :set_order_note, only: [:show, :edit, :update, :destroy]

  def new
    @order_note = @order.order_notes.build

    respond_to do |format|
      format.js {}
    end
  end

  def edit
    respond_to do |format|
      format.js {}
    end
  end

  def create
    @order_note = @order.order_notes.build(order_note_params)
    @order_note.save
    respond_to do |format|
      format.js {}
    end
  end

  def update
    @order_note.update(order_note_params)
    respond_to do |format|
      format.js {}
    end
  end

  def destroy
    @order_note.destroy
    respond_to do |format|
      format.js {}
    end
  end

  private
    def set_order_note
      @order_note = @order.order_notes.find(params[:id])
    end

    def set_order
      @order = Order.find(params[:order_id])
    end

    def order_note_params
      params.require(:order_note).permit(:subject, :body)
    end
end
