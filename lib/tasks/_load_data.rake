# # This task will take the AllSets file and create CardSet and Card objects.
# # For conventions sake, some camel cased keys in the json file are changed
# # to snake case and a couple fields are irrelevant and removed entirely:
# # (oldCode, gathererCode, onlineOnly, magicRaritiesCodes, etc)
#
# task :load_data => :environment do
#
#   json = File.read('lib/assets/AllSets.2.11.4.json')
#   sets = JSON.parse(json)
#
#   sets.each do |set_key, set_data|
#     cards = set_data["cards"]
#     set_data["setType"] = set_data["type"]
#     set_data["online_only"] = set_data["onlineOnly"]
#     set_data["set_type"] = set_data["setType"]
#     set_data["release_date"] = DateTime.parse(set_data["releaseDate"])
#
#     # Delete fields that were either renamed or will be removed.
#     set_data.delete("type")
#     set_data.delete("cards")
#     set_data.delete("magicRaritiesCodes")
#     set_data.delete("booster")
#     set_data.delete("releaseDate")
#     set_data.delete("setType")
#     set_data.delete("gathererCode")
#     set_data.delete("border")
#     set_data.delete("oldCode")
#     set_data.delete("onlineOnly")
#
#     set = CardSet.create!(set_data)
#
#     cards.each_with_index do |card_data, index|
#       print "#{index} - #{card_data['multiverseid']}"
#       card_data["card_type"] = card_data["type"]
#       card_data["card_set_id"] = set.id
#       card_data["mana_cost"] = card_data["manaCost"]
#       card_data["set_code"] = set.code
#
#       card_data.delete("type")
#       card_data.delete("manaCost")
#       card_data.delete("releaseDate")
#       card_data.delete("reserved")
#
#       set.cards.create!(card_data)
#     end
#   end
#
#   # Set current_standard
#   # "The sets I will mainly be renting from in the beginning are Theros, Born of the Gods, Journey into Nyx, M15 and Khans of Tarkir."
#   # set_code - "THS" "BNG" "JOU" "M15"
#
#   standard_sets = CardSet.where(code:["THS", "BNG", "JOU", "M15", "KTK"])
#   standard_sets.each do |card_set|
#     card_set.current_standard = true
#     card_set.save
#   end
#
#
#   # Create site settings objects for each of the default prices
#   [['price-by-rarity-mr', '100'], ['price-by-rarity-r', '50'], ['price-by-rarity-uc', '30'], ['price-by-rarity-c', '10']].each do |chunk|
#     SiteSetting.create(name:chunk[0], value:chunk[1])
#   end
#
#   # Create inventory
#   standard_sets.each do |card_set|
#     card_set.cards.each do |card|
#       card.inventory_cards.create!(status:'inventory')
#     end
#   end
#
# end
