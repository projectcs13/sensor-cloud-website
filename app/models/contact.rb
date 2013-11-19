
class Contact < MailForm::Base
	attribute :name,      :validate => true
	attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
	attribute :message,      :validate => true
	attribute :subject

	# Declare the e-mail headers. It accepts anything the mail method
	# in ActionMailer accepts.
	def headers
		{
			:subject => %("#{subject}"),
			:to => "projcs2013@googlegroups.com",
			:from => %("#{name}" <#{email}>)
		}
	end
end
