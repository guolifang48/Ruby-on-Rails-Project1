class TemplateDecksController < ApplicationController

  def index
    @template_decks = TemplateDeck.all
  end

  def show
    @template_deck = TemplateDeck.find(params[:id])
  end

  def rent
    @template_deck
  end


  def rent
    @template_deck = TemplateDeck.find(params[:id])
    @template_deck.template_deck_cards.each do |template_deck_card|

      card = template_deck_card.card
      if card.present?
        order_card = @cart.order_cards.find_by(card_id:card.id)
        if order_card.blank?
          order_card = @cart.order_cards.build(card_id:card.id, quantity:template_deck_card.quantity, current_price:card.raw_price)
        else
          theoretical_quantity = order_card.quantity + template_deck_card.quantity
          order_card.quantity = (theoretical_quantity > 4) ? 4 : theoretical_quantity
        end
        order_card.save
      end
    end

    respond_to do |format|
      flash[:success] = 'Standard deck added to cart'
      format.html { redirect_to cart_path }
    end
  end


end