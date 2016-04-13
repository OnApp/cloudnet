## Gets the list of disputes from Stripe which has been created in the last 24 hours. 
## Parses them to find the payment receipt and then the account associated with the charge.
## Shuts down all the servers in the account and blocks / places them under validation for admin to review.

class DisputeManager
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed

  def perform
    disputes = Payments.new.list_disputes (Time.zone.now - 1.day).beginning_of_day.to_i
    disputes.each do |dispute|
      begin
        # Skip this dispute if it has been already parsed before
        next unless dispute['metadata']['payment_receipt_id'].blank?
        
        payment_receipt = PaymentReceipt.find_by_reference dispute["charge"]
        # Skip if it can't find a matching payment record in db
        next if payment_receipt.blank?
        
        account = payment_receipt.account
        next if account.blank?
        account.user.create_activity(:chargeback, owner: account.user, params: { amount: dispute['amount'], currency: dispute['currency'], reason: dispute['reason'], status: dispute['status'], payment_receipt_id: payment_receipt.id })
        
        account.user.servers.map { |server| block_server(server) }
        
        # Notify user and support
        NotifyUsersMailer.notify_server_validation(account.user, account.user.servers).deliver_now
        SupportTasks.new.perform(:notify_server_validation, account.user, account.user.servers) rescue nil
        
        # Log the IP addresses associated with the account to risky ip addresses list for future use
        account.log_risky_ip_addresses
        
        # Log the billing cards associated with the account to risky cards list for future use
        account.log_risky_cards
        
        update_dispute(dispute["id"], payment_receipt)
        
      rescue Exception => e
        ErrorLogging.new.track_exception(e, extra: { dispute: dispute["charge"], source: 'DisputeManager' })
      end
    end
  end
  
  # Retrieve and update dispute object at Stripe with payment receipt and account info
  def update_dispute(dispute_id, payment_receipt)
    stripe_dispute = Payments.new.get_dispute dispute_id
    stripe_dispute.metadata = {payment_receipt_id: payment_receipt.id, payment_receipt_ref: payment_receipt.receipt_number, account: payment_receipt.account_id}
    stripe_dispute.save
  end
  
  # Shutdown and put the server under validation, eventually blocking the server on next refresh
  def block_server(server)
    return if server.validation_reason > 0
    ServerTasks.new.perform(:shutdown, server.user_id, server.id)
    server.create_activity :shutdown, owner: server.user
    server.update!(validation_reason: 4)
    server.create_activity :validation, owner: server.user, params: { reason: server.validation_reason }
  end
end
