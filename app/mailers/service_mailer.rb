class ServiceMailer < ActionMailer::Base
  default from: "lits-notifications@umbc.edu"

  def updated_schedule_email(opts={})
    @student      = opts[:student]
    @editor       = opts[:editor]
    @old_schedule = opts[:old_sched]
    @new_schedule = opts[:new_sched]

    # decide what kind of update this is
    @action = if @old_schedule.nil?
      :created
    elsif @new_schedule.nil?
      :deleted
    else
      :updated
    end

    # did this update come from the schedule's owner?
    @subject = if @student == @editor
      "#{@student.name(:full)} #{@action} a schedule"
    else
      "#{@editor.name(:full)} #{@action} a schedule for #{@student.name(:full)}"
    end

    # build robust array of email recipients (no nils or duplicates)
    receivers = Array(opts[:admin]).push(opts[:student]).compact
    addresses = receivers.map { |rec| rec.mail }.compact.uniq

    # send those emails!
    addresses.each { |address| mail to: address, subject: @subject }
  end
end
