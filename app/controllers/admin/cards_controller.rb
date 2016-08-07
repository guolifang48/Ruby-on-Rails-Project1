class Admin::CardsController < ApplicationController
  include CardsHelper

  before_action :authorize_admin

  def search
    @cards = Card.with_inventory.search_by_name(params[:term].downcase).paginate(page:params[:page], per_page:500)
    respond_to do |format|
      format.json {
        render json: @cards.map{ |c| { label:c.name, value:c.id, desc:'this is a test', card_image_url:card_image(c, crop:true), card_color_and_type:card_color_and_type(c), card_text:(c.text.present? ? c.text.truncate(110, separator: /\s/) : ''), card_price:"$#{c.get_price}", card_rarity:c.rarity, search_cards_url:search_cards_path(term:c.name.downcase) }}
      }
      format.html {}
    end
  end

  def edit
    @card = Card.find(params[:id])
    respond_to do |format|
      format.js {}
    end
  end

  def update
    @card = Card.find(params[:id])
    if @card.update(card_params)
      respond_to do |format|
        format.js {}
        format.json { head :no_content }
      end
    end
  end

  private

  def card_params
    params.require(:card).permit(:price_in_dollars, :inventory)
  end

end
