require "sinatra"
require "json"
require "sequel"
require "byebug"
require 'securerandom'
require 'redis'

class Auth

  attr_accessor :client_info, :error
  def initialize(api)
    @api = api
  end

  def authenticate!
    @error = 401 unless !(@api.request.env['HTTP_X_API_KEY'].blank?)
    @client_info = @api.redis.hgetall(@api.request.env['HTTP_X_API_KEY'])
    @error = 401 unless @api.request.env['HTTP_X_SECRET_KEY'] == client_info['secret_key']
  end

  def create_user!
    @error = 401 unless @api.request.env['HTTP_X_SECRET_KEY'] == @api.api_config['secret_key']
    @client_info = {
      'client_id' => @api.params[:client_id],
      'api_key' => SecureRandom.uuid,
      'secret_key' => SecureRandom.uuid
    }
    [:db_name, :db_server, :db_user, :db_password].each do |key|
      if (@api.params[key])
        @client_info[key.to_s] = params[key]
      end
    end

    @api.redis.mapped_hmset(@client_info['api_key'], @client_info)
  end
end
