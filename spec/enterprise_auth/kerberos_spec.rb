require 'mongo'
require 'support/lite_constraints'

RSpec.configure do |config|
  config.extend(LiteConstraints)
end

describe 'kerberos authentication' do
  require_mongo_kerberos

  let(:user) do
   "#{ENV['SASL_USER']}%40#{ENV['SASL_HOST'].upcase}"
  end

  let(:host) do
    "#{ENV['SASL_HOST']}"
  end

  let(:kerberos_db) do
    "#{ENV['KERBEROS_DB']}"
  end

  let(:auth_source) do
    "#{ENV['SASL_DB']}"
  end

  let(:uri) do
    uri = "mongodb://#{user}@#{host}/#{kerberos_db}?authMechanism=GSSAPI&authSource=#{auth_source}"
  end

  let(:client) do
    Mongo::Client.new(uri)
  end

  let(:doc) do
    client.database[:test].find.first
  end

  it 'correctly authenticates' do
    expect(doc['kerberos']).to eq(true)
    expect(doc['authenticated']).to eq('yeah')
  end

  context 'when canonicalize_host_name is true' do
    let(:host) do
      "#{ENV['IP_ADDR']}"
    end

    let(:uri) do
      uri = "mongodb://#{user}@#{host}/#{kerberos_db}?authMechanism=GSSAPI&authSource=#{auth_source}&authMechanismProperties=CANONICALIZE_HOST_NAME:true"
    end

    it 'correctly authenticates when using the IP' do
      expect(doc['kerberos']).to eq(true)
      expect(doc['authenticated']).to eq('yeah')
    end
  end
end
