require "bigdecimal"

module FineAnts
  module Adapters
    class Zillow
      def initialize(credentials)
        @user = credentials[:user]
      end

      def login
        true # No login necessary
      end

      def download
        visit "https://www.zillow.com/homedetails/xxxx/#{@user}_zpid/?fullpage=true"

        zestimate = all('.ds-home-details-chip p span:last-child').last.text

        [{
          adapter: :zillow,
          user: @user,
          id: @user,
          name: find('.ds-address-container').text,
          amount: zestimate.scan(/[.0-9]/).join.to_f
        }]
      end
    end
  end
end
