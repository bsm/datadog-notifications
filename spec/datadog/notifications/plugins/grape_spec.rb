require 'spec_helper'

describe Datadog::Notifications::Plugins::Grape do
  include Rack::Test::Methods

  let(:app) do
    unauthorized = Class.new(RuntimeError)

    sub_api = Class.new(Grape::API) do
      version 'v1'
      prefix  'api'

      get('versioned') { "OK" }
    end

    Class.new(Grape::API) do

      rescue_from unauthorized do |e|
        error!({ message: "unauthorized", error: '401 Unauthorized' }, 401)
      end

      get 'echo/:key1/:key2' do
        "#{params['key1']} #{params['key2']}"
      end

      get '/rescued' do
        raise unauthorized.new("unauthorized")
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
      "api.request:1|c|#custom:tag,env:test,host:test.host,more:tags,method:GET,path:/echo/KEY1/KEY2,status:200",
      "api.request.time:333|ms|#custom:tag,env:test,host:test.host,more:tags,method:GET,path:/echo/KEY1/KEY2,status:200",
    ])
  end

  it 'should support namespaces and versioning' do
    get '/api/v1/sub/versioned.txt'
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

  it 'should handle rescued errors' do
    get '/rescued'
    expect(last_response.status).to eq(401)

    expect(buffered).to eq([
      "api.request:1|c|#custom:tag,env:test,host:test.host,more:tags,method:GET,path:/rescued,status:401",
      "api.request.time:333|ms|#custom:tag,env:test,host:test.host,more:tags,method:GET,path:/rescued,status:401",
    ])
  end

  it 'should not report paths on 404s' do
    get '/sub/missing'
    expect(last_response.status).to eq(404)

    expect(buffered).to eq([])
  end

end
