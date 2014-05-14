require 'spec_helper'

describe Amplitude do

  let(:url) { 'http://example.tld' }
  let(:torrents) do
    path = "#{File.dirname(__FILE__)}/fixtures/fake_response.json"
    File.read(path)
  end
  let(:mock_response) { double(code: 200, headers: '') }

  before(:each) do
    Amplitude.configure do |config|
      config.username = 'user'
      config.password = 'pass'
      config.url = url
    end
  end

  describe '#all' do
    it 'should retrieve all torrents' do
      expected = {
        body: {
          method: 'torrent-get',
          arguments: {
            fields: Amplitude::DEFAULT_FIELDS
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_arguments = JSON.parse(torrents)['arguments']
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return(mock_arguments)
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      result = Amplitude.all
      expect(result.length).to eq(4)
      expect(result.first['totalSize']).to eq(991_952_896)
    end
  end

  describe '#find' do
    it 'should find a torrent' do
      expected = {
        body: {
          method: 'torrent-get',
          arguments: {
            ids: [2],
            fields: Amplitude::DEFAULT_FIELDS
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      collection = JSON.parse(torrents)['arguments']['torrents']
      found_torrent = collection.select do |e|
        e['id'] == 2
      end
      mock_torrents = double
      mock_torrents.should_receive(:[]).once.with('torrents')
        .and_return(found_torrent)
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return(mock_torrents)
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      result = Amplitude.find(2)
      expect(result.length).to eq(1)
      expect(result.first['totalSize']).to eq(1_010_827_264)
    end
    it 'should find 2 torrents with extra field' do
      expected = {
        body: {
          method: 'torrent-get',
          arguments: {
            ids: [3, 4],
            fields: Amplitude::DEFAULT_FIELDS + ['extra']
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      collection = JSON.parse(torrents)['arguments']['torrents']
      found_torrent = collection.select do |e|
        e['id'] == 3 || e['id'] == 4
      end
      mock_torrents = double
      mock_torrents.should_receive(:[]).once.with('torrents')
        .and_return(found_torrent)
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return(mock_torrents)
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      result = Amplitude.find([3, 4], ['extra'])
      expect(result.length).to eq(2)
      expect(result.first['totalSize']).to eq(4_603_249_765)
    end
  end

  describe '#torrent_set' do
    it 'should not fail' do
      expected = {
        body: {
          method: 'torrent-set',
          arguments: 'the_arguments'
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).once.with('arguments')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      Amplitude.set('the_arguments')
    end
  end

  describe '#start' do
    it 'should not fail' do
      expected = {
        body: {
          method: 'torrent-start',
          arguments: {
            ids: [1]
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).once.with('arguments')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      Amplitude.start(1)
    end
  end

  describe '#start_now' do
    it 'should not fail' do
      expected = {
        body: {
          method: 'torrent-start-now',
          arguments: {
            ids: [1]
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).once.with('arguments')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      Amplitude.start_now(1)
    end
  end

  describe '#stop' do
    it 'should not fail' do
      expected = {
        body: {
          method: 'torrent-stop',
          arguments: {
            ids: [1]
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).once.with('arguments')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      Amplitude.stop(1)
    end
  end

  describe '#verify' do
    it 'should not fail' do
      expected = {
        body: {
          method: 'torrent-verify',
          arguments: {
            ids: [1]
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).once.with('arguments')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      Amplitude.verify(1)
    end
  end

  describe '#reannounce' do
    it 'should not fail' do
      expected = {
        body: {
          method: 'torrent-reannounce',
          arguments: {
            ids: [1]
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).once.with('arguments')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      Amplitude.reannounce(1)
    end
  end

  describe '#add' do
    it 'should return the added torrent' do
      expected = {
        body: {
          method: 'torrent-add',
          arguments: { filename: 'test-file' }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_torrents = double
      mock_torrents.should_receive(:[]).once.with('torrent-duplicate')
        .and_return(false)
      mock_torrents.should_receive(:[]).once.with('torrent-added')
        .and_return('added-torrent')
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return(mock_torrents)
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)

      result = Amplitude.add('test-file')
      expect(result).to eq('added-torrent')
    end
  end

  describe '#remove' do
    context 'remove 1 file' do
      it 'should not fail' do
        expected = {
          body: {
            method: 'torrent-remove',
            arguments: {
              'delete-local-data' => false,
              ids: [1]
            }
          }.to_json,
          headers: { 'x-transmission-session-id' => '' }
        }
        mock_response.should_receive(:[]).once.with('arguments')
        Amplitude::Client.should_receive(:post).with('/', expected)
          .and_return(mock_response)
        Amplitude.remove(1)
      end
    end
    context 'remove more than one file and delete data' do
      it 'should not fail' do
        expected = {
          body: {
            method: 'torrent-remove',
            arguments: {
              'delete-local-data' => true,
              ids: [1, 2]
            }
          }.to_json,
          headers: { 'x-transmission-session-id' => '' }
        }
        mock_response.should_receive(:[]).once.with('arguments')
        Amplitude::Client.should_receive(:post).with('/', expected)
          .and_return(mock_response)
        Amplitude.remove([1, 2], true)
      end
    end
    context 'remove more than one file and explicitly without deleting data' do
      it 'should not fail' do
        expected = {
          body: {
            method: 'torrent-remove',
            arguments: {
              'delete-local-data' => false,
              ids: [1, 2, 3]
            }
          }.to_json,
          headers: { 'x-transmission-session-id' => '' }
        }
        mock_response.should_receive(:[]).once.with('arguments')
        Amplitude::Client.should_receive(:post).with('/', expected)
          .and_return(mock_response)
        Amplitude.remove([1, [2, 3]], false)
      end
    end
  end

  describe '#move' do
    context 'move 1 file' do
      it 'should not fail' do
        expected = {
          body: {
            method: 'torrent-set-location',
            arguments: {
              location: 'dest',
              move: false,
              ids: [1]
            }
          }.to_json,
          headers: { 'x-transmission-session-id' => '' }
        }
        mock_response.should_receive(:[]).once.with('arguments')
        Amplitude::Client.should_receive(:post).with('/', expected)
          .and_return(mock_response)
        Amplitude.move(1, 'dest')
      end
    end
    context 'move more than one file with move options to true' do
      it 'should not fail' do
        expected = {
          body: {
            method: 'torrent-set-location',
            arguments: {
              location: 'dest',
              move: true,
              ids: [1, 2]
            }
          }.to_json,
          headers: { 'x-transmission-session-id' => '' }
        }
        mock_response.should_receive(:[]).once.with('arguments')
        Amplitude::Client.should_receive(:post).with('/', expected)
          .and_return(mock_response)
        Amplitude.move([1, 2], 'dest', true)
      end
    end
  end

  describe '#rename' do
    # no more than 1 file can be renamed
    # https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt#L437
    it 'should return the moved file' do
      expected = {
        body: {
          method: 'torrent-rename-path',
          arguments: {
            path: 'the_path',
            name: 'new_name',
            ids: [1]
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return('move_infos')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      result = Amplitude.rename(1, 'the_path', 'new_name')
      expect(result).to eq('move_infos')
    end
  end

  describe '#session_get' do
    it 'should return response arguments' do
      expected = {
        body: {
          method: 'session-get',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return('response')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      result = Amplitude.session_get
      expect(result).to eq('response')
    end
  end

  describe '#session_get' do
    it 'should return response arguments' do
      expected = {
        body: {
          method: 'session-set',
          arguments: {
            foo: 'bar',
            baz: 'quux'
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return('response')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      result = Amplitude.session_set(
        foo: 'bar',
        baz: 'quux'
      )
      expect(result).to eq('response')
    end
  end

  describe '#session_stats' do
    it 'should return response arguments' do
      expected = {
        body: {
          method: 'session-stats',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return('response')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      result = Amplitude.session_stats
      expect(result).to eq('response')
    end
  end

  describe '#update_blocklist' do
    it 'should return the blocklist\'s size' do
      expected = {
        body: {
          method: 'blocklist-update',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_blocklist = double
      mock_blocklist.should_receive(:[]).once.with('blocklist-size')
        .and_return(1337)
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return(mock_blocklist)
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      result = Amplitude.update_blocklist
      expect(result).to eq(1337)
    end
  end

  describe '#test_port' do
    it 'should return the blocklist\'s size' do
      expected = {
        body: {
          method: 'port-test',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_port = double
      mock_port.should_receive(:[]).once.with('port-is-open')
        .and_return('yes or maybe not')
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return(mock_port)
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      result = Amplitude.test_port
      expect(result).to eq('yes or maybe not')
    end
  end

  describe '#close_session' do
    it 'should not fail' do
      expected = {
        body: {
          method: 'session-close',
          arguments: {}
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_response.should_receive(:[]).once.with('arguments')
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      Amplitude.close_session
    end
  end

  describe '#prioritize' do
    context 'top action' do
      it 'should not fail' do
        expected = {
          body: {
            method: 'queue-move-top',
            arguments: {
              ids: [1]
            }
          }.to_json,
          headers: { 'x-transmission-session-id' => '' }
        }
        mock_response.should_receive(:[]).once.with('arguments')
        Amplitude::Client.should_receive(:post).with('/', expected)
          .and_return(mock_response)
        Amplitude.prioritize(1, 'top')
      end
    end
    context 'bottom action' do
      it 'should not fail' do
        expected = {
          body: {
            method: 'queue-move-bottom',
            arguments: {
              ids: [1]
            }
          }.to_json,
          headers: { 'x-transmission-session-id' => '' }
        }
        mock_response.should_receive(:[]).once.with('arguments')
        Amplitude::Client.should_receive(:post).with('/', expected)
          .and_return(mock_response)
        Amplitude.prioritize(1, 'bottom')
      end
    end
    context 'up action' do
      it 'should not fail' do
        expected = {
          body: {
            method: 'queue-move-up',
            arguments: {
              ids: [1]
            }
          }.to_json,
          headers: { 'x-transmission-session-id' => '' }
        }
        mock_response.should_receive(:[]).once.with('arguments')
        Amplitude::Client.should_receive(:post).with('/', expected)
          .and_return(mock_response)
        Amplitude.prioritize(1, 'up')
      end
    end
    context 'down action' do
      it 'should not fail' do
        expected = {
          body: {
            method: 'queue-move-down',
            arguments: {
              ids: [1]
            }
          }.to_json,
          headers: { 'x-transmission-session-id' => '' }
        }
        mock_response.should_receive(:[]).once.with('arguments')
        Amplitude::Client.should_receive(:post).with('/', expected)
          .and_return(mock_response)
        Amplitude.prioritize(1, 'down')
      end
    end
  end

  describe '#free_space' do
    it 'should the free space' do
      expected = {
        body: {
          method: 'free-space',
          arguments: {
            path: 'the_path'
          }
        }.to_json,
        headers: { 'x-transmission-session-id' => '' }
      }
      mock_blocklist = double
      mock_blocklist.should_receive(:[]).once.with('size-bytes')
        .and_return(1337)
      mock_response.should_receive(:[]).twice.with('arguments')
        .and_return(mock_blocklist)
      Amplitude::Client.should_receive(:post).with('/', expected)
        .and_return(mock_response)
      result = Amplitude.free_space('the_path')
      expect(result).to eq(1337)
    end
  end
end
