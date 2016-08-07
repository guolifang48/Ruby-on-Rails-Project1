class CardSetsController < ApplicationController
  include CardsHelper

  def index
    @expansion_sets = CardSet.by_sets(:expansion_sets)
    @special_sets = CardSet.by_sets(:special_sets)
    @core_sets = CardSet.by_sets(:core_sets)
  end

  def show
    @card_set = CardSet.find(params[:id])
    @cards = @card_set.cards.with_inventory.paginate(page:params[:page], per_page:500)
  end

end
