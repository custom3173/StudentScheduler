module Features
  module SessionHelpers

    # hacked login, but the alternative is
    # not having integration tests when
    # using a Shibboleth based auth
    def sign_in_as(group)
      FactoryGirl.create(:user, umbcusername: 'test_user', group: group)
      page.driver.browser.process_and_follow_redirects(:get, '/shibbolite/login', {}, {'umbcusername' => 'test_user'})
    end
  end
end