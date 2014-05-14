require 'spec_helper'

describe Amplitude::Client do

  let(:url) { 'http://example.tld' }

  before(:each) do
    Amplitude.configure do |config|
      config.username = 'user'
      config.password = 'pass'
      config.url = url
    end
  end

  context 'Simple client request with arguments in response' do
    it 'should return arguments value' do
      mock_response = double(
        code: 200,
        headers: '',
        body: { 'arguments' => 'value', 'result' => 'success' }.to_json
      )
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return('value')

      Amplitude::Client.should_receive(:post).with(
        '/',
        body: {
          method: 'test',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      ).and_return(mock_response)

      response = Amplitude.client.action('test')
      expect(response).to eq('value')
    end
  end

  context 'Simple client request with no argument in response' do
    it 'should return response body' do
      mock_response = double(
        code: 200,
        headers: '',
        body: 'the_response'
      )
      mock_response.should_receive(:[]).once.with('arguments').and_return(false)

      Amplitude::Client.should_receive(:post).with(
        '/',
        body: {
          method: 'test',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      ).and_return(mock_response)

      response = Amplitude.client.action('test')
      expect(response.body).to eq('the_response')
    end
  end

  context 'Session ID conflict' do
    it 'should call Transmission twice and return response body' do
      mock_response = double(
        code: 409,
        headers: { 'x-transmission-session-id' => 'a_session_id' },
        body: 'the_response'
      )

      Amplitude::Client.should_receive(:post).ordered.with(
        '/',
        body: {
          method: 'test',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      ).and_return(mock_response)

      mock_response = double(
        code: 200,
        headers: '',
        body: 'the_response'
      )
      mock_response.should_receive(:[]).once.with('arguments').and_return(false)

      Amplitude::Client.should_receive(:post).ordered.with(
        '/',
        body: {
          method: 'test',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => 'a_session_id' }
      ).and_return(mock_response)

      response = Amplitude.client.action('test')
      expect(response.body).to eq('the_response')
    end
  end

  context 'Basic auth failure' do
    it 'should raise an AuthenticationError' do
      mock_response = double(
        code: 401,
        headers: '',
        body: ''
      )

      Amplitude::Client.should_receive(:post).ordered.with(
        '/',
        body: {
          method: 'test',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      ).and_return(mock_response)

      expect { Amplitude.client.action('test') }
        .to raise_error(Amplitude::AuthenticationError) { |e|
          expect(e.instance_variable_get(:@message)).to eq('Unauthorized')
          expect(e.instance_variable_get(:@http_status)).to eq(401)
        }

    end
  end

  context 'Transmission error' do
    it 'should raise an ActionError' do
      mock_response = double(
        code: 500,
        headers: '',
        body: "Well it didn't work..."
      )

      Amplitude::Client.should_receive(:post).ordered.with(
        '/',
        body: {
          method: 'test',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      ).and_return(mock_response)

      expect { Amplitude.client.action('test') }
        .to raise_error(Amplitude::ActionError) { |e|
          expect(e.instance_variable_get(:@message))
            .to eq("Well it didn't work...")
          expect(e.instance_variable_get(:@http_status)).to eq(500)
        }
    end
  end
end
