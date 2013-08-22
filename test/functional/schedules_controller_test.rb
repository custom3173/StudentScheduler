require 'test_helper'

class SchedulesControllerTest < ActionController::TestCase
  setup do
    @schedule = schedules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:schedules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create schedule" do
    assert_difference('Schedule.count') do
      post :create, schedule: { absent: @schedule.absent, description: @schedule.description, end_date: @schedule.end_date, end_time: @schedule.end_time, friday: @schedule.friday, monday: @schedule.monday, permanent: @schedule.permanent, saturday: @schedule.saturday, start_date: @schedule.start_date, start_time: @schedule.start_time, student_id: @schedule.student_id, sunday: @schedule.sunday, thursday: @schedule.thursday, tuesday: @schedule.tuesday, wednesday: @schedule.wednesday }
    end

    assert_redirected_to schedule_path(assigns(:schedule))
  end

  test "should show schedule" do
    get :show, id: @schedule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @schedule
    assert_response :success
  end

  test "should update schedule" do
    put :update, id: @schedule, schedule: { absent: @schedule.absent, description: @schedule.description, end_date: @schedule.end_date, end_time: @schedule.end_time, friday: @schedule.friday, monday: @schedule.monday, permanent: @schedule.permanent, saturday: @schedule.saturday, start_date: @schedule.start_date, start_time: @schedule.start_time, student_id: @schedule.student_id, sunday: @schedule.sunday, thursday: @schedule.thursday, tuesday: @schedule.tuesday, wednesday: @schedule.wednesday }
    assert_redirected_to schedule_path(assigns(:schedule))
  end

  test "should destroy schedule" do
    assert_difference('Schedule.count', -1) do
      delete :destroy, id: @schedule
    end

    assert_redirected_to schedules_path
  end
end
