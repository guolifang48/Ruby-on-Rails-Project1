json.array!(@order_notes) do |order_note|
  json.extract! order_note, :id, :order_id, :subject, :body
  json.url order_note_url(order_note, format: :json)
end
