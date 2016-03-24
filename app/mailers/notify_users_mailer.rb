class NotifyUsersMailer < ActionMailer::Base
  default from: ENV['MAILER_NOTIFICATIONS_DEFAULT_FROM']

  def notify_email(user, subject, body)
    @user = user
    @body = body
    mail(to: @user[:email], subject: subject)
  end

  def notify_location_email(user_id, subject, body, location_id)
    @user = User.find(user_id)
    @body = body
    @location = Location.find(location_id)
    @servers = @user.servers.select { |s| s.location_id == @location.id }
    mail(to: @user.email, subject: subject)
  end
  
  def notify_stuck_state(user, server)
    @user = user
    @server = server
    recipients = [@user.email, ENV['MAILER_SUPPORT_MAIN']]
    mail(to: recipients.join(","), subject: "#{ENV['BRAND_NAME']} Your server is still building")
  end
  
  def notify_server_validation(user, server)
    @user = user
    @server = server
    mail(to: @user.email, subject: "#{ENV['BRAND_NAME']} Your server is placed under validation")
  end
  
  def notify_auto_topup(user, success)
    @user = user
    @success = success
    subject = @success ? 'Your Wallet has been topped up!' : 'Wallet top-up has failed'
    mail(to: @user[:email], subject: subject)
  end
end
