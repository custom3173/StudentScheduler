FactoryGirl.define do
  
  factory :student do
    username 'testguy1'
    admin    false

    factory :student_with_schedule do
      ignore do
        schedules_count 1
      end

      after(:create) do |student, evaluator|
        create_list(:schedule, evaluator.schedules_count, student: student)
      end
    end
  end

  factory :admin, class: Student do
    username 'testadmin1'
    admin    true
  end
end