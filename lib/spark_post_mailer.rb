class SparkPostMailer < ActionMailer::Base
  def self.smtp_settings
    { :address              => Settings['spark_post.address'],
      :port                 => Settings['spark_post.port'],
      :domain               => Settings['spark_post.domain'],
      :user_name            => Settings['spark_post.login'],
      :password             => Settings['spark_post.password'],
      :authentication       => 'login',
      :enable_starttls_auto => true
    }
  end
end
