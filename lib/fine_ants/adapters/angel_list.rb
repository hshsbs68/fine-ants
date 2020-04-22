require "bigdecimal"

module FineAnts
  module Adapters
    class AngelList
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://angel.co/login"

        fill_in "user[email]", with: @user
        fill_in "user[password]", with: @password

        click_button "Log In"

        begin
          page.has_text? "Enter the 6 digit code"
          return false
        rescue Capybara::ElementNotFound
          verify_login!
          return true
        end
      end

      def two_factor_response(answer)
        fill_in "two_factor[otp_attempt]", with: answer

        click_button "Log in"
        verify_login!
      end

      def download
        click_link "Invest"
        click_link "Portfolio Overview"

        invested = find('.results .s-grid0 div:nth-child(2) .acumin-pro').text

        [{
          adapter: :angel_list,
          user: @user,
          id: @user,
          name: "Investments",
          amount: invested.scan(/[.0-9]/).join().to_f,
        }]
      end

      private

      def verify_login!
        find_logout_button
      rescue
        raise FineAnts::LoginFailedError.new
      end

      def find_logout_button
        find('header > div a:last-child img').click
        find('a[href="/logout"]', text: "Log Out")
      end
    end
  end
end
