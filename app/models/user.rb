class User < ActiveRecord::Base
  rolify
  has_secure_password

  has_many :orders
  has_many :verification_quizzes

  before_create :create_session_token

  before_save { |user| user.email = user.email.try(:downcase) }

  validates :first_name,  presence: true, length: { maximum: 50 }
  validates :last_name,  presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, :if => :password
  validates :password_confirmation, presence: true, :if => :password, :on => :create

  validates_acceptance_of :terms

  validates_inclusion_of :time_zone,
     :in => ActiveSupport::TimeZone.zones_map(&:name).keys,
     :message => "is not a valid time zone"

  after_validation { self.errors.messages.delete(:password_digest) }

  scope :non_guest, -> { where("users.guest is null") }

  def User.new_session_token
    SecureRandom.urlsafe_base64
  end

  def primary_verification_quiz
    verification_quizzes.first
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def update_customer(stripe_card_token)
    if stripe_customer_id.blank?
      customer = Stripe::Customer.create(
        :description => email,
        :card => stripe_card_token
      )
      update_columns(stripe_customer_id:customer.id, last_4_digits:last_4_digits, card_type:card_type)
    elsif stripe_customer_id.present? && stripe_card_token.present?
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      card = customer.cards.create(card:stripe_card_token)
      customer.default_card = card.id
      update_columns( last_4_digits:card.last4, card_type:card.brand)
    else
      return
    end
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def move_cart_to(user)
    new_cart = orders.last_cart
    if new_cart.present? && (new_cart.order_cards.count > 0)
      old_cart = user.orders.last_cart
      old_cart.destroy if old_cart.present?
      new_cart.update_columns(user_id:user.id)
    end
  end

  def prepare_for_destroy
    cancel_existing_orders
    remove_stripe_customer
    destroy_invitation
  end

  def cancel_existing_orders
    existing_orders = orders.authorized_not_yet_shipped
    existing_orders.each do |order|
      order.cancel_order('Account Deletion')
    end
  end

  def remove_stripe_customer
    if stripe_customer_id.present?
      customer = Stripe::Customer.retrieve(stripe_customer_id)
      customer.delete
    end
  end

  def destroy_invitation
    invitations = Invitation.where(recipient_email:email)
    invitations.destroy_all
  end

  def verification_status
    if primary_verification_quiz.present? && (verification.blank?)
      'needs review'
    elsif primary_verification_quiz.blank?
      'quiz not complete'
    elsif primary_verification_quiz.present? && (verification == 'verified')
      'verified'
    elsif primary_verification_quiz.present? && (verification == 'failed')
      'failed'
    end
  end

  private

  def create_session_token
    self.session_token = User.encrypt(User.new_session_token)
  end
end
