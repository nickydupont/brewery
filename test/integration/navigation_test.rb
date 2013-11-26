require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
    test "you can signup and login and click on the activation link" do
        get '/users/new'
        assert_response :success

        user_attributes = FactoryGirl.attributes_for(:user)
        post_via_redirect '/users', auth_core_user: user_attributes
        assert_equal '/', path

        mail = ActionMailer::Base.deliveries.last
        email_address = user_attributes[:email]
        user = Brewery::AuthCore::User.where(email: email_address).first
        assert_not_nil user
        assert_operator mail.body, :=~, /\/users\/confirm\/#{user.perishable_token}/
        assert_not user.active

        get '/'
        assert_response :success

        get_via_redirect "/users/confirm/#{user.perishable_token}"
        assert_equal '/', path
        user.reload
        assert user.active
    end
end

