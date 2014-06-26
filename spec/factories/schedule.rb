FactoryGirl.define do

  factory :schedule do
    start_date Date.today
    end_date   Date.tomorrow
    start_time Time.now
    end_time   Time.now + 2.hours

    monday     true
    tuesday    true
    wednesday  true
    thursday   true
    friday     true
    saturday   true
    sunday     true

    permanent  false
    absent     false

    description 'test'
    student
  end
end