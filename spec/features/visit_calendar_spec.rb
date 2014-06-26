require 'spec_helper'

feature 'user visits the calendar' do

  background do
    visit root_path

    @student = FactoryGirl.create :student_with_schedule
  end

  scenario 'user is taken to the calendar' do
    #expect(@student.schedules).to eq 'something'
    expect(page).to have_content 'Calendar'
    expect(page).to have_content @student.username
  end

  scenario 'user sees student schedules'
  scenario 'user can change the week displayed'
end