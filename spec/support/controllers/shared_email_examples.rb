# TODO delete if it's never used in any tests
module Controllers

  # action is a proc that includes a valid controller action call
  shared_examples 'it sends emails' do |action, options={}|
    options[:number] ||= 1
    it "sends #{options[:number]} emails" do
      expect{action.call}.to change{emails.count}.by(options[:number])
    end


    if options[:to]
      Array(options[:to]).each do |to|
        it "sends an email to #{to}"
      end
    end

    if options[:cc]
      Array(options[:cc]).each do |cc|
        it "cc's an email to #{cc}"
      end
    end

    def emails
      ActionMailer::Base.deliveries
    end
  end
end