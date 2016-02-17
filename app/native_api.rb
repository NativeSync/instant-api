require "sinatra"
require "json"
require "sequel"
require "byebug"
require 'securerandom'
require 'redis'
require_relative 'auth'
require_relative 'request/authenticated_request_base'
require_relative 'request/api_spec'
require_relative 'request/get'
require_relative 'request/get_recent'
require_relative 'request/create'
require_relative 'request/update'
require_relative 'request/delete'

class NativeApi < Sinatra::Base
  attr_accessor :api_config, :redis, :client_info, :db, :object_schema, :object_name, :request, :params
  configure do
    set :raise_errors, true
    set :show_exceptions, false
  end

  before do
    @api_config = JSON.parse(File.read('examples/dvdrental_config.json'))
    @redis = Redis.new(:host => "localhost", :port => 6379, :db => 15)
    content_type :json
  end

  def authenticated_request(request_class)
    auth = Auth.new(self)
    auth.authenticate!
    error auth.error unless auth.error.nil?
    @client_info = auth.client_info
    connect_string = @api_config['db_connection']
    [:db_name, :db_server, :db_user, :db_password].each do |key|
      connect_string.gsub!(/{{client_#{key}}}/, client_info[key.to_s] ? client_info[key.to_s] : '')
    end
    @db = Sequel.connect(connect_string)

    request = request_class.new(self)

    # error out if there's an error, otherwise return results
    error request.error unless request.error.nil?
    request.results.to_json
  end

  def get_object_schema!
    @object_name = params[:object].singularize
    error 401 unless @api_config['sync_objects'].keys.include? object_name
    @object_schema = @api_config['sync_objects'][@object_name]
  end

  post '/user' do
    auth = Auth.new(self)
    auth.create_user!
    error auth.error unless auth.error.nil?
    auth.client_info.to_json
  end

  get '/nativeapi/api_spec' do
    authenticated_request(Request::ApiSpec)
  end

  get '/:object/recent' do
    get_object_schema!
    authenticated_request(Request::GetRecent)
  end

  get '/:object' do
    get_object_schema!
    authenticated_request(Request::Get)
  end

  post '/:object' do
    get_object_schema!
    authenticated_request(Request::Create)
  end

  put '/:object' do
    get_object_schema!
    authenticated_request(Request::Update)
  end

  delete '/:object' do
    get_object_schema!
    authenticated_request(Request::Delete)
  end
end
