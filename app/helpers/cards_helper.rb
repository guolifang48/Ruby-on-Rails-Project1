module CardsHelper
  require 'uri'

  def card_image(card, crop = false)
    version = crop ? '.crop' : ''
    #Format: http://mtgimage.com/set/<set code>/<card name>.jpg
    # URI.encode( "http://mtgimage.com/set/#{ card.set_code }/#{ card.imageName }#{ version }.jpg" )
    URI.encode( "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=#{ card.multiverseid }&type=card" )
  end

  def card_color_and_type(card)
    "#{mana_cost(card)} #{card.card_type}"
  end

  def abbreviate_rarity(card)
    # => ["Uncommon", "Rare", "Common", "Basic Land", "Mythic Rare", "Special"]

    case card.rarity
    when 'Mythic Rare'
      'MR'
    when 'Rare'
      'R'
    when 'Uncommon'
      'UC'
    when 'Common'
      'C'
    when 'Basic Land'
      'L'
    when 'Special'
      'S'
    end
  end

  def mana_cost(card)
    mana_cost = card.mana_cost
    if !mana_cost
      return ''
    end

    mana_cost_array = mana_cost.split('}{')
    mana_cost_array.first.gsub!('{', '')
    mana_cost_array.last.gsub!('}', '')

    # img_array = mana_cost_array.collect{|m| "<img src='http://mtgimage.com/symbol/mana/#{m.downcase}/16.png' />" }
    img_array = mana_cost_array.collect{|m| "<img src='http://gatherer.wizards.com/Handlers/Image.ashx?size=small&name=#{m.downcase}&type=symbol' />" }

    return img_array.join.html_safe
  end

  def mana_icons(card)
    if card.colors == nil
      return
    end

    icon_urls = mana_tags(card.colors)
    html = ''
    icon_urls.each do |url|
      html += "<span><img src='#{url}' /></span>"
    end

    return html.html_safe
  end

  def mana_tags(colors)
    #Format: http://mtgimage.com/symbol/mana/u/16.png

    mana_array = []

    colors.each do |color|
      case color
      when "Blue"
        mana = 'u'
      when "Black"
        mana = 'b'
      when "White"
        mana = 'w'
      when "Green"
        mana = 'g'
      when "Red"
        mana = 'r'
      end
      mana_url = "http://mtgimage.com/symbol/mana/#{mana}/16.png"
      mana_array << mana_url
    end

    return mana_array
  end

  def parse_reference_deck_by_type(reference_cards)
    hash = Hash.new
    types = card_type_array
    reference_cards.each do |reference_card|
      types.each_with_index do |type, index|
        break unless reference_card.card
        if (reference_card.card.types.include? type)
          (hash[index] ||= []) << reference_card
          break
        end
        if index == types.size - 1
          (hash[2] ||= []) << reference_card
          break
        end
      end
    end
    return hash.sort
  end

  def parse_cards_by_type(cards)
    hash = Hash.new
    types = card_type_array
    cards.sort_by{|c| c.name }.each do |card|
      types.each_with_index do |type, index|
        if (card.types.include? type)
          (hash[index] ||= []) << card
          break
        end
        if index == types.size - 1
          (hash[2] ||= []) << reference_card
          break
        end
      end
    end
    return hash.sort
  end

  def value_in_dollars(value)
    "%.2f" % (value.to_f / 100)
  end

  def card_type_array
    return %w(Creature Planeswalker Spell Land Sideboard)
#    return %w(Creature Planeswalker Instant Enchantment Sorcery Artifact Tribal Summon Vanguard Interrupt Player Eaturecray Planes Scheme Phenomenon Conspiracy Land)
  end

end
