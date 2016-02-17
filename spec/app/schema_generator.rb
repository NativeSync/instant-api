require "spec_helper"
require 'json'

# TODO: figure out how to inject json dependencies into API
# works off the dvdrental_config.json dataset
RSpec.describe NativeApi do
  def app
    NativeApi # this defines the active application for this test
  end

  before(:all) do
    # create a user in redis and store its data
   # create a user in redis and store its data
    header 'X_SECRET_KEY',  'yeah_yo'
    post '/user', {:client_id => '14'}
    client_info = JSON.parse(last_response.body)
    expect(client_info.keys).to include('api_key', 'secret_key', 'client_id')
    @api_key = client_info['api_key']
    @secret_key = client_info['secret_key']
    @client_id = 14
  end

  describe "GET native API representation" do
    it "gives a valid json result" do
      header 'X_SECRET_KEY', @secret_key
      header 'X_API_KEY', @api_key
      get "/nativeapi/api_spec"
      debugger
      expect(last_response.body).to be_an_instance_of("".class)
      expect(last_response.status).to eq(200)
    end
  end
end
