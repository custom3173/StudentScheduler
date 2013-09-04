class ServiceMailer < ActionMailer::Base
  default from: "lits-notifications@umbc.edu"

  def test_email(recipient)
    @recipient = recipient

    mail(:to => recipient.email, :subject => "Test email")
  end

  # recipient is the Student who should receive the email
  # student is the Student that owns the schedule
  # editor is the Student who created/updated the schedule
  def updated_schedule_email(recipient, student, editor, old_schedule, new_schedule)
    @recipient = recipient
    @student = student
    @editor = editor
    @old_schedule = old_schedule
    @new_schedule = new_schedule
    @self_edited = editor.username == student.username

    @self_edited ? subject = "#{student.username} updated a schedule" : subject = "#{editor.username} updated a schedule for #{student.username}"
    mail(:to => recipient.email, :subject => subject)
  end

  def created_schedule_email(recipient, student, editor, schedule)
    @recipient = recipient
    @student = student
    @editor = editor
    @schedule = schedule
    @self_edited = editor.username == student.username

    @self_edited ? subject = "#{student.username} created a new schedule" : subject = "#{editor.username} created a schedule for #{student.username}"
    mail(:to => recipient.email, :subject => subject)
  end

  def deleted_schedule_email(recipient, student, editor, schedule)
    @recipient = recipient
    @student = student
    @editor = editor
    @schedule = schedule
    @self_edited = editor.username == student.username

    @self_edited ? subject = "#{student.username} deleted a schedule" : subject = "#{editor.username} deleted a schedule for #{student.username}"
    mail(:to => recipient.email, :subject => subject)
  end

  def called_out_tomorrow_email(recipient, student, editor, schedule)
    @recipient = recipient
    @student = student
    @editor = editor
    @schedule = schedule
    @self_edited = editor.username == student.username

    @self_edited ? subject = "#{student.username} has called out of work tomorrow" : subject = "#{editor.username} has cancelled #{@student.username}'s shift tomorrow}"
    mail(:to => recipient.email, :subject => subject)
  end
end
