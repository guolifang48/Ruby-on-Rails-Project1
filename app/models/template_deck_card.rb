class TemplateDeckCard < ActiveRecord::Base
  belongs_to :template_deck
  belongs_to :card

  scope :deck, -> { where(sideboard:false) }
  scope :sideboard, -> { where(sideboard:true) }

end
