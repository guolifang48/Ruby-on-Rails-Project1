class CardsController < ApplicationController
  include CardsHelper

  def search

    if params[:origin] == 'cart' && @cart.order_cards.present?
      @cards = Card.with_inventory.not_in_cart(@cart).search_by_name(params[:term].downcase).paginate(page:params[:page], per_page:500)
    else
      @cards = Card.with_inventory.search_by_name(params[:term].downcase).paginate(page:params[:page], per_page:500)
    end

    respond_to do |format|
      format.json {
        render json: @cards.map{ |c| { label:c.name, value:c.id, desc:'this is a test', card_image_url:card_image(c, crop:true), card_color_and_type:card_color_and_type(c), card_text:(c.text.present? ? c.text.truncate(110, separator: /\s/) : ''), raw_price:c.raw_price, card_price:"$#{c.get_price}", card_rarity:c.rarity, search_cards_url:search_cards_path(term:c.name.downcase) }}
      }
      format.html {}
    end
  end

end
