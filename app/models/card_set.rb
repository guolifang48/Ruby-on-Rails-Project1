class CardSet < ActiveRecord::Base
  has_many :cards

  enum category: [:expansion_sets, :special_sets, :core_sets]

  scope :current_standard, -> {
    where(current_standard:true)
  }

  def self.with_inventory
    select("card_sets.*").joins("JOIN cards on cards.card_set_id = card_sets.id").where("cards.inventory > 0").uniq
  end

  def self.by_sets(category)
    send(category).eager_load(:cards).where('cards.inventory > 1').order('position ASC')
  end

  def inventory
    cards.sum(:inventory)
  end

end