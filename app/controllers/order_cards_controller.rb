class OrderCardsController < ApplicationController
  include CardsHelper
#  skip_before_action :verify_authenticity_token

  def new
    @order_card = @cart.order_cards.build(card_id:params[:card_id])
    respond_to do |format|
      format.js { render 'order_cards/new' }
    end
  end

  def create_or_update
    @card = Card.find(params[:id])
    @order_card = @cart.order_cards.find_by(card_id:@card.id)
    if @order_card.blank?
      @order_card = @cart.order_cards.build(card_id:@card.id, quantity:params[:qty], current_price:@card.raw_price)
    else
      @order_card.quantity = @order_card.quantity + params[:qty].to_i
      if @order_card.quantity > 4
        @order_card.quantity = 4
      end
    end

    if @order_card.quantity <= 0
      @order_card.destroy
    else
      @order_card.save
    end

    respond_to do |format|
      format.js {
        if params[:origin] == 'cart'
          @order_cards_hash = parse_reference_deck_by_type(@cart.order_cards)
          render 'order_cards/update_cart'
        else
          render 'order_cards/update'
        end
      }
    end
  end

  # The create action is by the quick add form
  # on the cart page and the up chevron on the card set show.

  def create
    @card = Card.find(order_card_params[:card_id])
    @order_card = @cart.order_cards.find_by(card_id:order_card_params[:card_id])
    if @order_card.blank?
      @order_card = @cart.order_cards.build(card_id:@card.id, quantity:order_card_params[:quantity], current_price:@card.raw_price)
    else
      @order_card.quantity = order_card_params[:quantity]
      if @order_card.quantity > 4
        @order_card.quantity = 4
      end
    end

    @order_card.save
    @order_cards_hash = parse_reference_deck_by_type(@cart.order_cards)

    respond_to do |format|
      format.js {
        if params[:origin] == 'cart'
          render 'order_cards/update_cart'
        else
          render 'order_cards/create'
        end
      }
    end
  end

  def edit
    @order_card = @cart.order_cards.find(params[:id])
    respond_to do |format|
      format.js {
        if params[:origin] == 'cart'
          render 'order_cards/cart_edit'
        elsif params[:origin] == 'card_set'
          render 'order_cards/edit_card_set_order_card'
        else
          render 'order_cards/edit'
        end
      }
    end
  end

  def update
    @order_card = @cart.order_cards.find(params[:id])
    @order_card.update(order_card_params)

    respond_to do |format|
      format.js {
        if params[:origin] == 'cart'
          @order_cards_hash = parse_reference_deck_by_type(@cart.order_cards)
          render 'order_cards/update_cart'

        elsif params[:origin] == 'card_set'
          @card = @order_card.card
          render 'order_cards/update_card_set'

        else
          render 'order_cards/update'
        end
      }
    end
  end

  def destroy
    @order_card = @cart.order_cards.find(params[:id])
    @card = @order_card.card
    @order_card.destroy

    respond_to do |format|
      format.js {
        if params[:origin] == 'cart'
          @order_cards_hash = parse_reference_deck_by_type(@cart.order_cards)
          render 'order_cards/update_cart'
        elsif params[:origin] == 'card_set'
          render 'order_cards/update_card_set'
        end
      }
    end
  end

  private

  def order_card_params
    params.require(:order_card).permit(:card_id, :quantity, :current_price)
  end

end
