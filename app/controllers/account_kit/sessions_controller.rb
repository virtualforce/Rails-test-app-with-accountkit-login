module AccountKit
  class SessionsController < ApplicationController
    before_action :config_app_secret, only: [:new]

    def new
      @user = User.new
    end

    def create
      @access_token, @expires_at, @user_id = access_token(params[:code])
      response = AccountKit.me(@access_token)
      json_response = JSON.parse(response.body)
      @email_arddess = json_response['email']['address'] if json_response['email']
      @phone_number = json_response['phone']['number'] if json_response['phone']
      render 'signed_in'
    end

    private

    def config_app_secret
      AccountKit.configure do |config|
        config.require_app_secret = params[:require_app_secret].present?
        config.app_id = params[:app_id] || app_id_for(params[:require_app_secret].present?)
        config.app_secret = params[:app_secret] || app_secret_for(params[:require_app_secret].present?)
      end
    end

    def access_token(code)
      response = AccountKit.access_token(code)
      json_response = JSON.parse(response.body)
      puts "*"*100, json_response
      [json_response['access_token'], json_response['token_refresh_interval_sec'], json_response['id']]
    end

    def app_id_for(require_app_secret)
      require_app_secret ? '1763782337215572' : '1763782337215572'
    end

    def app_secret_for(require_app_secret)
      require_app_secret ? 'b4cc742088a35e8512a9341c33616edc' : 'b4cc742088a35e8512a9341c33616edc'
    end
  end
end
