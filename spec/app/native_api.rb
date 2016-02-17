require "spec_helper"
require 'json'
require_relative '../mock/actor'

# TODO: figure out how to inject json dependencies into API
# works off the dvdrental_config.json dataset
RSpec.describe NativeApi do
  def app
    NativeApi # this defines the active application for this test
  end

  before(:all) do
    # create a user in redis and store its data
    header 'X_SECRET_KEY',  'yeah_yo'
    post '/user', {:client_id => '14'}
    client_info = JSON.parse(last_response.body)
    expect(client_info.keys).to include('api_key', 'secret_key', 'client_id')
    @api_key = client_info['api_key']
    @secret_key = client_info['secret_key']
    @client_id = 14

  end

  describe "GET recent" do
    it "gives a 401 with no auth" do
      get "/actors/recent"
      expect(last_response.body).to eq("")
      expect(last_response.status).to eq(401)
    end

    it "gives a 401 with invalid auth" do
      header 'X_SECRET_KEY', 'dung'
      header 'X_API_KEY', 'beetle'
      get "/actors/recent", :api_key => 5, :secret_key => 6
      expect(last_response.body).to eq("")
      expect(last_response.status).to eq(401)
    end

    it "Returns valid objects when properly queried" do
      header 'X_SECRET_KEY', @secret_key
      header 'X_API_KEY', @api_key
      get "/actors/recent", {:from_date => 1.month.ago, :to_date => Time.now()}
      expect(JSON.parse(last_response.body).count).to be > 0
      expect(last_response.status).to eq(200)
    end

    it "gives a 401 with invalid object" do
      header 'X_SECRET_KEY', 'dung'
      header 'X_API_KEY', 'beetle'
      get "/factors/recent"
      expect(last_response.body).to eq("")
      expect(last_response.status).to eq(401)
    end
  end

  describe "GET all by page" do
    it "Gives a list of actors" do
      header 'X_SECRET_KEY', @secret_key
      header 'X_API_KEY', @api_key
      get "/actors", {:page => 0}
      expect(JSON.parse(last_response.body).count).to be > 0
      expect(last_response.status).to eq(200)
    end
  end

  describe "POST object" do
    it "gives a 401 with invalid auth" do
      header 'X_SECRET_KEY', 'dung'
      header 'X_API_KEY', 'beetle'
      post "/actor"
      expect(last_response.body).to eq("")
      expect(last_response.status).to eq(401)
    end

    it "returns the proper values when supplied a valid object to insert" do
      header 'X_SECRET_KEY', @secret_key
      header 'X_API_KEY', @api_key
      actors = [
        get_actor('test1'),
        get_actor('test2')
      ]
      post "/actor", :actors => actors

      results = JSON.parse(last_response.body)

      expect(results).to be_an_instance_of([].class)
      # we want ids to be strings incase theyre non-numeric GUIDS
      expect(results.first['id']).to be_an_instance_of(''.class)
      expect(results.first['success']).to eq(true)
      expect(last_response.status).to eq(200)
    end

    it "returns errors when supplied an invalid object to insert" do
      header 'X_SECRET_KEY', @secret_key
      header 'X_API_KEY', @api_key
      actors = [
        {invalid_field: 'test1'},
        get_actor('test2')
      ]
      post "/actor", :actors => actors

      results = JSON.parse(last_response.body)

      expect(results).to be_an_instance_of([].class)
      expect(results.first['success']).to eq(false)
      expect(results.first['error']).to be_an_instance_of(''.class)
      expect(last_response.status).to eq(200)
    end
  end

  describe "PUT object" do
    it "gives a 401 with invalid auth" do
      header 'X_SECRET_KEY', 'dung'
      header 'X_API_KEY', 'beetle'
      put "/actor"
      expect(last_response.body).to eq("")
      expect(last_response.status).to eq(401)
    end

    it "returns the proper values when supplied a valid object to update" do
      header 'X_SECRET_KEY', @secret_key
      header 'X_API_KEY', @api_key
      actors = [
        get_actor('test2', 3),
        get_actor('test2', 4)
      ]
      put "/actor", :actors => actors

      results = JSON.parse(last_response.body)

      expect(results).to be_an_instance_of([].class)
      expect(results.first['id']).to be_an_instance_of(''.class)
      expect(results.first['success']).to eq(true)
      expect(last_response.status).to eq(200)
    end

    it "returns errors when supplied an invalid object to update" do
      header 'X_SECRET_KEY', @secret_key
      header 'X_API_KEY', @api_key
      actors = [
        {invalid_field: 'test1', actor_id: 2},
        get_actor('test2', 3)
      ]
      put "/actor", :actors => actors

      results = JSON.parse(last_response.body)

      expect(results).to be_an_instance_of([].class)
      expect(results.first['success']).to eq(false)
      expect(results.first['error']).to be_an_instance_of(''.class)
      expect(last_response.status).to eq(200)
    end
  end
end
