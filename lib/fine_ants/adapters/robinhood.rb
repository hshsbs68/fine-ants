require "bigdecimal"

module FineAnts
  module Adapters
    class Robinhood
      def initialize(credentials)
        @user = credentials[:user]
        @password = credentials[:password]
      end

      def login
        visit "https://robinhood.com/login"

        fill_in "username", with: @user
        fill_in "password", with: @password

        click_button "Sign In"
        click_button "Text Me"

        begin
          has_text? "Portfolio"
          return false
        rescue Capybara::ElementNotFound
          verify_login!
          return true
        end
      end

      def two_factor_response(answer)
        fill_in currently_with: "", with: answer

        click_button "Confirm"
        verify_login!
      end

      def download
        all('a', text: "Account").last.click

        accounts = all('section section .col-13 > div').map(&:text)

        data = accounts.map { |account|
          {
            adapter: :robinhood,
            user: @user,
            id: id_for(account),
            name: name_for(account),
            amount: total_for(account),
          }
        }

        all('a', text: "Account").last.click
        find('a[href="/login"]', text: "Log Out").click

        data
      end

      private

      def verify_login!
        find_logout_button
      rescue
        raise FineAnts::LoginFailedError.new
      end

      def find_logout_button
        click_link "Account"
        find('a[href="/login"]', text: "Log Out")
      end

      def id_for(account)
        account.split("\n").first
      end

      def name_for(account)
        account.split("\n").first
      end

      def total_for(account)
        account.split("\n").last.scan(/[.0-9]/).join().to_f
      end
    end
  end
end
