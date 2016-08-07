# This task will take the contents of the card_sets directory and process each json file.
# For conventions sake, some camel cased keys in the json file are changed
# to snake case and a couple fields are irrelevant and removed entirely:
# (oldCode, gathererCode, onlineOnly, magicRaritiesCodes, etc)

task :create_admin => :environment do
  user1 = User.create(first_name:'Chris', last_name:'Hawkins', email:'christopher.james.hawkins@gmail.com', password:'testing', password_confirmation:'testing', time_zone:'Eastern Time (US & Canada)')
  user1.add_role :admin

  user2 = User.create(first_name:'Aaron', last_name:'Little', email:'aaroninniigata@hotmail.com', password:'testing', password_confirmation:'testing', time_zone:'Eastern Time (US & Canada)')
  user2.add_role :admin

end


task :load_card_sets => :environment do

  dir_path = 'lib/assets/card_sets'
  Dir.foreach(dir_path) do |file|
    next if file == '.' or file == '..'
    path = "#{dir_path}/#{file}"
    json = File.read(path)
    set_data = JSON.parse(json)

    next if CardSet.where(code: set_data["set_code"]).present?

    cards = set_data["cards"]
    set_data["setType"] = set_data["type"]
    set_data["online_only"] = set_data["onlineOnly"]
    set_data["set_type"] = set_data["setType"]
    set_data["release_date"] = DateTime.parse(set_data["releaseDate"])

    # Delete fields that were either renamed or will be removed.
    set_data.delete("type")
    set_data.delete("cards")
    set_data.delete("magicRaritiesCodes")
    set_data.delete("booster")
    set_data.delete("releaseDate")
    set_data.delete("setType")
    set_data.delete("gathererCode")
    set_data.delete("border")
    set_data.delete("oldCode")
    set_data.delete("onlineOnly")

    set = CardSet.create!(set_data)

    cards.each_with_index do |card_data, index|
      print "#{index} - #{card_data['multiverseid']}"
      card_data["card_type"] = card_data["type"]
      card_data["card_set_id"] = set.id
      card_data["mana_cost"] = card_data["manaCost"]
      card_data["set_code"] = set.code

      card_data.delete("type")
      card_data.delete("manaCost")
      card_data.delete("releaseDate")
      card_data.delete("reserved")

      set.cards.create!(card_data)
    end

  end
end

task :load_setup_data => :environment do
  # Set current_standard
  # "The sets I will mainly be renting from in the beginning are Theros, Born of the Gods, Journey into Nyx, M15 and Khans of Tarkir."
  # set_code - "THS" "BNG" "JOU" "M15"

  standard_sets = CardSet.where(code:["THS", "BNG", "JOU", "M15", "KTK", "FRF"])
  standard_sets.each do |card_set|
    card_set.current_standard = true
    card_set.save
  end


  # Create site settings objects for each of the default prices
  [['price-by-rarity-mr', '100'], ['price-by-rarity-r', '50'], ['price-by-rarity-uc', '30'], ['price-by-rarity-c', '10'], ['price-by-rarity-bl', '20']].each do |chunk|
    SiteSetting.create(name:chunk[0], value:chunk[1])
  end

  # Create inventory
  # standard_sets.each do |card_set|
  #   card_set.cards.each do |card|
  #     card.inventory = rand(0 .. 50)
  #     card.save
  #   end
  # end

end

task :load_new_cards, [:id, :json_code] => :environment do |t, args|
  return unless args.id || args.json_code

  uri = "http://mtgjson.com/json/#{args.json_code}.json"
  responce = RestClient.get uri, content_type: :json, accept: :json rescue '{}'
  json_data = JSON.parse(responce)

  set = CardSet.find(args.id)

  json_data['cards'].each_with_index do |card_data, index|
    print "#{index} - #{card_data['multiverseid']}"

    card_data['card_type'] = card_data['type']
    card_data['card_set_id'] = set.id
    card_data['mana_cost'] = card_data['manaCost']
    card_data['set_code'] = set.code

    card_data.delete('type')
    card_data.delete('manaCost')
    card_data.delete('releaseDate')
    card_data.delete('reserved')

    set.cards.create!(card_data)
  end
end

task :load_origin => :environment do

  file_path = File.join(Rails.root, 'lib', 'assets', 'card_sets', 'ORI.json')

  json = File.read(file_path)
  set_data = JSON.parse(json)

  next if CardSet.where(code: set_data['set_code']).present?

  cards = set_data['cards']
  set_data['setType'] = set_data['type']
  set_data['online_only'] = set_data['onlineOnly']
  set_data['set_type'] = set_data['setType']
  set_data['release_date'] = DateTime.parse(set_data['releaseDate'])

  set_data.delete('type')
  set_data.delete('cards')
  set_data.delete('magicRaritiesCodes')
  set_data.delete('booster')
  set_data.delete('releaseDate')
  set_data.delete('setType')
  set_data.delete('gathererCode')
  set_data.delete('border')
  set_data.delete('oldCode')
  set_data.delete('onlineOnly')
  set_data.delete('languagesPrinted')

  set = CardSet.create!(set_data)

  cards.each_with_index do |card_data, index|
    print "#{index} - #{card_data['multiverseid']}"
    card_data['card_type'] = card_data['type']
    card_data['card_set_id'] = set.id
    card_data['mana_cost'] = card_data['manaCost']
    card_data['set_code'] = set.code

    card_data.delete('type')
    card_data.delete('manaCost')
    card_data.delete('releaseDate')
    card_data.delete('reserved')

    set.cards.create!(card_data)
  end
end

task :load_battle => :environment do

  file_path = File.join(Rails.root, 'lib', 'assets', 'card_sets', 'BFZ.json')

  json = File.read(file_path)
  set_data = JSON.parse(json)

  next if CardSet.where(code: set_data['set_code']).present?

  cards = set_data['cards']
  set_data['setType'] = set_data['type']
  set_data['online_only'] = set_data['onlineOnly']
  set_data['set_type'] = set_data['setType']
  set_data['release_date'] = DateTime.parse(set_data['releaseDate'])

  set_data.delete('type')
  set_data.delete('cards')
  set_data.delete('magicRaritiesCodes')
  set_data.delete('booster')
  set_data.delete('releaseDate')
  set_data.delete('setType')
  set_data.delete('gathererCode')
  set_data.delete('border')
  set_data.delete('oldCode')
  set_data.delete('onlineOnly')
  set_data.delete('languagesPrinted')

  set = CardSet.create!(set_data)

  cards.each_with_index do |card_data, index|
    print "#{index} - #{card_data['multiverseid']}"
    card_data['card_type'] = card_data['type']
    card_data['card_set_id'] = set.id
    card_data['mana_cost'] = card_data['manaCost']
    card_data['set_code'] = set.code

    card_data.delete('type')
    card_data.delete('manaCost')
    card_data.delete('releaseDate')
    card_data.delete('reserved')

    set.cards.create!(card_data)
  end
end
