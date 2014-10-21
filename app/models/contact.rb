class Contact < MailForm::Base

	attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
	attribute :message,   :validate => true
	attribute :name
	attribute :subject

	# Declare the e-mail headers. It accepts anything the mail method
	# in ActionMailer accepts.
	def headers
		{
			:subject => %("#{subject}"),
			:to => "iot-framework-support@ericsson.com",
			:from => %("#{name}" <#{email}>)
		}
	end

end
