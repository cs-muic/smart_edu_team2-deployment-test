# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email_address   :string           not null
#  first_name      :string
#  is_active       :boolean          default(TRUE)
#  last_name       :string
#  password_digest :string           not null
#  role            :string           default("unassigned")
#  uuid            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#  index_users_on_uuid           (uuid) UNIQUE
#
# app/models/user.rb
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :payments, dependent: :destroy

  ROLES = %w[admin teacher student unassigned].freeze

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 8, maximum: 20 }, if: :password_required?
  validates :role, presence: true, inclusion: { in: ROLES }
  validates :uuid, presence: true, uniqueness: true

  before_validation :generate_uuid, on: :create

  after_initialize do
    self.role ||= "unassigned" if new_record?
  end

  def subscribed?
    subscriptions.where(status: "active").any?
  end

  def active_subscription
    subscriptions.where(status: "active").order(created_at: :desc).first
  end

  # Create or retrieve Omise customer
  def omise_customer
    if omise_customer_id.present?
      Omise::Customer.retrieve(omise_customer_id)
    else
      customer = Omise::Customer.create(
        email: email_address,
        description: "User ID: #{id} - #{first_name} #{last_name}"
      )
      update(omise_customer_id: customer.id)
      customer
    end
  rescue Omise::Error => e
    Rails.logger.error "Omise error: #{e.message}"
    nil
  end

  private

  def generate_uuid
    self.uuid ||= SecureRandom.uuid
  end

  def password_required?
    new_record? || password.present?
  end
end
