class TemplateDeck < ActiveRecord::Base
  has_many :template_deck_cards, dependent: :destroy
  has_many :cards, through: :template_deck_cards

  before_validation :ensure_name_has_a_value

  def price
    total = 0
    template_deck_cards.each do |template_deck_card|
      card_price = template_deck_card.card.get_price.to_f
      total += card_price * template_deck_card.quantity
    end
    return ("%.2f" % total)
  end

  protected
    def ensure_name_has_a_value
      if name.blank?
        self.name = "template_deck-#{Time.now.to_i}"
      end
    end

end
