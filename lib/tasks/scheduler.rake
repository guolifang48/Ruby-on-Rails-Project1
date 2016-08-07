desc "Email users when decks are due back soon."
task :send_deck_due_soon_emails => :environment do
  orders = Order.deck_due_back_soon.limit(20)
  orders.each do |order|
    OrdersMailer.deck_due_back_soon(order).deliver
    order.update_columns(due_back_warning:Time.zone.now)
    order.order_notes.create!(subject:'User has been sent due back soon warning')
  end
end

desc "Email users when decks are due back with shipped link."
task :send_deck_return_confirmation_links => :environment do
  orders = Order.deck_due_back.limit(20)
  orders.each do |order|
    OrdersMailer.deck_due_back(order).deliver
    order.update_columns(due_back_confirm:Time.zone.now)
    order.order_notes.create!(subject:'User has been sent return-confirm link')
  end
end

desc "Remove guest accounts more than two days old."
task :guest_record_cleanup => :environment do
  User.where(guest: :true).where("created_at < ?", 2.days.ago).destroy_all
end
