require 'spec_helper'

describe Datadog::Notifications::Plugins::ActiveRecord do

  it 'should send an increment and timing event for each query' do
    Post.all.to_a
    expect(buffered).to eq [
      'activerecord.sql:1|c|#custom:tag,env:test,host:test.host,query:post.load',
      'activerecord.sql.time:333|ms|#custom:tag,env:test,host:test.host,query:post.load',
    ]
  end

  it 'should support custom queries' do
    Post.find_by_sql('SELECT * FROM posts LIMIT 1').to_a
    expect(buffered).to eq [
      'activerecord.sql:1|c|#custom:tag,env:test,host:test.host,query:post.load',
      'activerecord.sql.time:333|ms|#custom:tag,env:test,host:test.host,query:post.load',
    ]
  end

end
