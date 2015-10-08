require 'spec_helper'

describe Datadog::Notifications::Plugins::Grape do
  include Rack::Test::Methods

  let(:app) do
    sub_api = Class.new(Grape::API) do
      version 'v1'
      prefix  'api'

      get('versioned') { "OK" }
    end

    Class.new(Grape::API) do
      get 'echo/:key1/:key2' do
        "#{params['key1']} #{params['key2']}"
      end

      namespace :sub do
        mount sub_api

        namespace :secure do
          get("/resource") { error!("forbidden", 403) }
        end
      end
    end
  end

  it 'should send an increment and timing event for each request' do
    get '/echo/1/1234'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('1 1234')

    expect(buffered).to eq([
      "api.request:1|c|#custom:tag,env:test,host:test.host,more:tags,method:GET,path:/echo/_key1_/_key2_,status:200",
      "api.request.time:333|ms|#custom:tag,env:test,host:test.host,more:tags,method:GET,path:/echo/_key1_/_key2_,status:200",
    ])
  end

  it 'should support namespaces and versioning' do
    get '/api/v1/sub/versioned'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to eq('OK')

    expect(buffered).to eq([
      "api.request:1|c|#custom:tag,env:test,host:test.host,more:tags,method:GET,path:/api/sub/versioned,status:200,version:v1",
      "api.request.time:333|ms|#custom:tag,env:test,host:test.host,more:tags,method:GET,path:/api/sub/versioned,status:200,version:v1",
    ])
  end

  it 'should support deep nesting' do
    get '/sub/secure/resource'
    expect(last_response.status).to eq(403)
    expect(last_response.body).to eq('forbidden')

    expect(buffered).to eq([
      "api.request:1|c|#custom:tag,env:test,host:test.host,more:tags,method:GET,path:/sub/secure/resource,status:403",
      "api.request.time:333|ms|#custom:tag,env:test,host:test.host,more:tags,method:GET,path:/sub/secure/resource,status:403",
    ])
  end

end
