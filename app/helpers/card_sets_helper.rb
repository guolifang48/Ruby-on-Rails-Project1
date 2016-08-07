module CardSetsHelper

  def set_logo(set_code, rarity = 'r', size = 256)
    #Format: http://mtgimage.com/symbol/set/<set code>/<rarity>/<size>.<format>
    # "http://mtgimage.com/symbol/set/#{set_code}/#{rarity}/#{size}.png"
    "http://gatherer.wizards.com/Handlers/Image.ashx?type=symbol&set=#{set_code}&size=medium&rarity=#{rarity}"
  end

end
