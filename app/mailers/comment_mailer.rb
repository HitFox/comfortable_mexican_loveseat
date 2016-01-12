class CommentMailer < ActionMailer::Base
  default from: ComfortableMexicanSofa.config.from_email

 def admin_mention(comment)
   @comment = comment
   
   mail(to: @comment.admins.pluck(:email), subject: t('.subject'))
 end
end
