class CommentMailer < ActionMailer::Base
  default from: ComfortableMexicanLoveseat.from_email

 def admin_mention(comment)
   @comment = comment
   
   mail(to: @comment.admins.pluck(:email), subject: t('.subject'))
 end
end
