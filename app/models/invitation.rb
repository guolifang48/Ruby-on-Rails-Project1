class Invitation < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  has_one :recipient, :class_name => 'User'

  validates_presence_of :recipient_email

  validate :recipient_is_not_registered_or_invited

  before_save do |invitation|
    invitation.recipient_email = invitation.recipient_email.try(:downcase)
  end

  before_create :generate_token

  private

  def recipient_is_not_registered_or_invited
    if User.find_by(email: recipient_email.downcase)
      errors.add :recipient_email, ' already registered'
    end
  end

  def generate_token
    self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
  end

end
