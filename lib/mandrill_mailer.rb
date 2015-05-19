class MandrillMailer < ActionMailer::Base
  def self.smtp_settings
    { :address              => Settings['mandrill.address'],
      :port                 => Settings['mandrill.port'],
      :domain               => Settings['mandrill.domain'],
      :user_name            => Settings['mandrill.login'],
      :password             => Settings['mandrill.password'],
      :authentication       => "plain",
      :enable_starttls_auto => true
    }
  end
end
