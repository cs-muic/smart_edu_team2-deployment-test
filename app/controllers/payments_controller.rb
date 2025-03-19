# app/controllers/payments_controller.rb
class PaymentsController < ApplicationController
  include Authentication

  before_action :authenticate_user, except: [:success, :failure, :webhook]
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def new
    # Display payment form
    redirect_to root_path, alert: "You're already subscribed!" if Current.user.subscribed?
  end

  def create
    # Get the token from the form
    token = params[:omise_token]
    plan = params[:plan]

    if token.blank?
      redirect_to new_payment_path, alert: "Missing card information"
      return
    end

    # Process using Omise
    begin
      # Create or retrieve a customer
      omise_customer = find_or_create_customer(token)

      # Store the customer ID with the user
      Current.user.update(omise_customer_id: omise_customer.id) unless Current.user.omise_customer_id.present?

      # Set up a subscription
      subscription = OmiseService.create_subscription(
        omise_customer.id,
        get_plan_id_for(plan)
      )

      # Create a subscription record in our database
      @subscription = Current.user.subscriptions.create!(
        plan_name: plan,
        omise_subscription_id: subscription.id,
        status: subscription.status,
        started_at: Time.now,
        expires_at: 1.month.from_now
      )

      # Create a payment record
      @payment = @subscription.payments.create!(
        user: Current.user,
        amount: get_plan_amount_for(plan),
        status: "successful",
        omise_charge_id: subscription.id, # Using subscription ID for reference
        paid_at: Time.now
      )

      redirect_to subscription_path(@subscription), notice: "Subscription successful! Thank you for your payment."
    rescue Omise::Error => e
      Rails.logger.error "Omise Error: #{e.message}"
      redirect_to new_payment_path, alert: "Payment error: #{e.message}"
    end
  end

  def show
    @payment = Current.user.payments.find(params[:id])
  end

  def success
    # Handle successful payments
    redirect_to root_path, notice: "Your payment was successful!"
  end

  def failure
    # Handle failed payments
    redirect_to root_path, alert: "Your payment could not be processed. Please try again."
  end

  def webhook
    # Handle Omise webhook events
    payload = JSON.parse(request.body.read)
    event = payload["data"]

    case payload["key"]
    when "charge.create"
      process_charge_create(event)
    when "charge.complete"
      process_charge_complete(event)
    when "subscription.create"
      process_subscription_create(event)
    when "subscription.delete"
      process_subscription_delete(event)
    end

    head :ok
  end

  private

  def find_or_create_customer(token)
    if Current.user.omise_customer_id.present?
      begin
        customer = OmiseService.retrieve_customer(Current.user.omise_customer_id)
        return customer
      rescue Omise::Error
        # Customer not found, create a new one
      end
    end

    # Create a new customer
    OmiseService.create_customer(Current.user, token)
  end

  def get_plan_id_for(plan_name)
    case plan_name
    when "premium"
      "plan_premium_monthly" # This should be created in your Omise dashboard
    else
      raise "Unknown plan: #{plan_name}"
    end
  end

  def get_plan_amount_for(plan_name)
    case plan_name
    when "premium"
      599.0 # ฿599 per month
    else
      0.0
    end
  end

  def process_charge_create(event)
    # Handle charge creation
  end

  def process_charge_complete(event)
    # Handle completed charge
    charge_id = event["id"]
    payment = Payment.find_by(omise_charge_id: charge_id)

    if payment && event["status"] == "successful"
      payment.update(status: "successful", paid_at: Time.now)
    elsif payment
      payment.update(status: event["status"])
    end
  end

  def process_subscription_create(event)
    # Handle subscription creation
  end

  def process_subscription_delete(event)
    # Handle subscription deletion/cancellation
    subscription_id = event["id"]
    subscription = Subscription.find_by(omise_subscription_id: subscription_id)

    if subscription
      subscription.update(status: "canceled")
    end
  end
end