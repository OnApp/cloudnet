require "rails_helper"

RSpec.describe AdminMailer, :type => :mailer do
  let(:user) { FactoryGirl.create(:user, notif_delivered: 11) }
  let(:from) { Mail::Address.new(ENV['MAILER_ADMIN_DEFAULT_FROM']) }
  
  describe "shutdown_action" do
    let(:mail) { AdminMailer.shutdown_action(user) }

    it "fills mailer queue" do
      mail.deliver_now
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Cloud.net: Automatic shutdown - #{user.full_name}")
      expect(mail.to).to eq(ENV['MAILER_ADMIN_RECIPIENTS'].delete(' ').split(","))
      expect(mail.from).to eq([from.address])
    end
    
    context "rendering" do
      before(:each) do
        send_mail :shutdown_action, user
      end
      
      it "assigns variables" do
        expect(assigns(:user)).to eq user
        expect(assigns(:pretty_negative_balance)).to eq "$0.00"
      end
    
      it "renders the body" do
        balance = assigns(:pretty_negative_balance)
        
        expect(response).to match("Admin SHUTDOWN notification!")
        expect(response).to match("The automatic shutdown was performed on all servers of #{CGI.escapeHTML(user.full_name)}.")
        expect(response).to include("negative balance on this account by #{balance}")
        expect(response).to match("There were 12 warnings delivered to that user.")
        expect(response).to match("profile: #{admin_user_url(user) }")
        expect(response).to match("After #{user.notif_before_destroy} notifications")
      end
    end
  end
  
  describe "destroy_warning" do
    let(:mail) { AdminMailer.destroy_warning(user) }

    it "fills mailer queue" do
      mail.deliver_now
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Cloud.net: DESTROY warning! - #{user.full_name}")
      expect(mail.to).to eq(ENV['MAILER_ADMIN_RECIPIENTS'].delete(' ').split(","))
      expect(mail.from).to eq([from.address])
    end
    
    context "rendering" do
      before(:each) do
        send_mail :destroy_warning, user
      end
      
      it "assigns variables" do
        expect(assigns(:user)).to eq user
        expect(assigns(:pretty_negative_balance)).to eq "$0.00"
      end
    
      it "renders the body" do
        balance = assigns(:pretty_negative_balance)

        expect(response).to match("Admin DESTROY warning!")
        expect(response).to match("all servers of #{CGI.escapeHTML(user.full_name)} will be destroyed soon.")
        expect(response).to include("negative balance on this account by #{balance}")
        expect(response).to match("There were 12 warnings delivered to that user.")
        expect(response).to match("profile: #{admin_user_url(user) }")
        expect(response).to match("After #{user.notif_before_destroy} notifications")
      end
    end
  end
  
  describe "request_for_server_destroy" do
    let(:mail) { AdminMailer.request_for_server_destroy(user) }

    it "fills mailer queue" do
      mail.deliver_now
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Cloud.net: DESTROY request! - #{user.full_name}")
      expect(mail.to).to eq(ENV['MAILER_ADMIN_RECIPIENTS'].delete(' ').split(","))
      expect(mail.from).to eq([from.address])
    end
    
    context "rendering" do
      before(:each) do
        send_mail :request_for_server_destroy, user
      end
      
      it "assigns variables" do
        expect(assigns(:user)).to eq user
        expect(assigns(:pretty_negative_balance)).to eq "$0.00"
      end
    
      it "renders the body" do
        balance = assigns(:pretty_negative_balance)

        expect(response).to match("Admin DESTROY request!")
        expect(response).to match("all servers of #{CGI.escapeHTML(user.full_name)} are scheduled to be destroyed.")
        expect(response).to include("negative balance on this account by #{balance}")
        expect(response).to match("There were 11 warnings delivered to that user.")
        expect(response).to match("profile: #{admin_user_url(user) }")
        expect(response).to match("log in to your admin account and confirm destroy")
      end
    end
  end
  
  describe "destroy_action" do
    let(:mail) { AdminMailer.destroy_action(user) }

    it "fills mailer queue" do
      mail.deliver_now
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    it "renders the headers" do
      expect(mail.subject).to eq("Cloud.net: Automatic destroy - #{user.full_name}")
      expect(mail.to).to eq(ENV['MAILER_ADMIN_RECIPIENTS'].delete(' ').split(","))
      expect(mail.from).to eq([from.address])
    end
    
    context "rendering" do
      before(:each) do
        send_mail :destroy_action, user
      end
      
      it "assigns variables" do
        expect(assigns(:user)).to eq user
        expect(assigns(:pretty_negative_balance)).to eq "$0.00"
      end
    
      it "renders the body" do
        balance = assigns(:pretty_negative_balance)
        
        expect(response).to match("Admin DESTROY notification!")
        expect(response).to match("The automatic destroy was performed on all servers of #{CGI.escapeHTML(user.full_name)}.")
        expect(response).to include("negative balance on this account by #{balance}")
        expect(response).to match("There were 11 warnings delivered to that user.")
        expect(response).to match("profile: #{admin_user_url(user) }")
      end
    end
  end
end