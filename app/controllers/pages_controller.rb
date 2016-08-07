class PagesController < ApplicationController
  def home
    @top_standard_decks = TemplateDeck.all
    @standard_sets = CardSet.current_standard
  end

  def terms
  end

  def contact
  end

  def faq
  end

  def about
  end
end
