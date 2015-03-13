class ServiceMailer < ActionMailer::Base
  default from: "lits-notifications@umbc.edu"

  def test_email(recipient)
    @recipient = recipient

    mail(:to => recipient.mail, :subject => "Test email")
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
    @self_edited = editor.umbcusername == student.umbcusername

    @self_edited ? subject = "#{student.umbcusername} updated a schedule" : subject = "#{editor.umbcusername} updated a schedule for #{student.umbcusername}"
    mail(:to => recipient.mail, :subject => subject)
  end

  def created_schedule_email(recipient, student, editor, schedule)
    @recipient = recipient
    @student = student
    @editor = editor
    @schedule = schedule
    @self_edited = editor.umbcusername == student.umbcusername

    @self_edited ? subject = "#{student.umbcusername} created a new schedule" : subject = "#{editor.umbcusername} created a schedule for #{student.umbcusername}"
    mail(:to => recipient.mail, :subject => subject)
  end

  def deleted_schedule_email(recipient, student, editor, schedule)
    @recipient = recipient
    @student = student
    @editor = editor
    @schedule = schedule
    @self_edited = editor.umbcusername == student.umbcusername

    @self_edited ? subject = "#{student.umbcusername} deleted a schedule" : subject = "#{editor.umbcusername} deleted a schedule for #{student.umbcusername}"
    mail(:to => recipient.mail, :subject => subject)
  end

  def called_out_tomorrow_email(recipient, student, editor, schedule)
    @recipient = recipient
    @student = student
    @editor = editor
    @schedule = schedule
    @self_edited = editor.umbcusername == student.umbcusername

    @self_edited ? subject = "#{student.umbcusername} has called out of work tomorrow" : subject = "#{editor.umbcusername} has cancelled #{@student.umbcusername}'s shift tomorrow}"
    mail(:to => recipient.mail, :subject => subject)
  end
end
