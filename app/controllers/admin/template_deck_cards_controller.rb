class Admin::TemplateDeckCardsController < ApplicationController
  include CardsHelper

  before_action :authorize_admin

  def new
    @template_deck = TemplateDeck.find(params[:template_deck_id])
    @template_deck_card = @template_deck.template_deck_cards.build

    respond_to do |format|
      format.js {}
    end
  end

  def create
    @template_deck = TemplateDeck.find(params[:template_deck_id])
    @template_deck_card = @template_deck.template_deck_cards.build(template_deck_card_params)
    @template_deck_card.save
    @template_deck_card_hash = parse_reference_deck_by_type(@template_deck.template_deck_cards.deck)
    @sideboard_template_deck_cards = @template_deck.template_deck_cards.sideboard
    respond_to do |format|
      format.js {}
    end
  end

  def edit
    @template_deck = TemplateDeck.find(params[:template_deck_id])
    @template_deck_card = @template_deck.template_deck_cards.find(params[:id])
    respond_to do |format|
      format.js {}
    end
  end

  def update
    @template_deck = TemplateDeck.find(params[:template_deck_id])
    @template_deck_card = @template_deck.template_deck_cards.find(params[:id])

    @template_deck_card.update(template_deck_card_params)
    @template_deck_card_hash = parse_reference_deck_by_type(@template_deck.template_deck_cards.deck)

    respond_to do |format|
      format.js {}
    end


    respond_to do |format|
      format.js {}
    end
  end

  def destroy
    @template_deck = TemplateDeck.find(params[:template_deck_id])
    @template_deck_card = @template_deck.template_deck_cards.find(params[:id])
    @template_deck_card.destroy
    @template_deck_card_hash = parse_reference_deck_by_type(@template_deck.template_deck_cards.deck)

    respond_to do |format|
      format.js {}
    end
  end

  private

  def template_deck_card_params
    params.require(:template_deck_card).permit(:card_id, :quantity, :sideboard)
  end

end
