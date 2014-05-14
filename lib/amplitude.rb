require 'httparty'
require_relative 'amplitude/errors/amplitude_error'
require_relative 'amplitude/errors/action_error'
require_relative 'amplitude/errors/authentication_error'
require_relative 'amplitude/client'

module Amplitude
  DEFAULT_FIELDS = %w(id name totalSize)
  PRIORITIZATION_ACTIONS = %w(up down top bottom)

  def self.client
    @client
  end

  def self.configure(&blk)
    options = OpenStruct.new
    yield(options)

    @client = Amplitude::Client.new(
      username: options.username,
      password: options.password,
      url: options.url,
      debug: options.debug || false
    )
  end

  def self.build_args(ids, opts = {})
    ids = [ids].flatten.uniq
    args = {}
    args[:ids] = ids if ids.length > 0
    opts.merge(args)
  end

  def self.ids_action(name, ids, opts = {})
    client.action(name, build_args(ids, opts))
  end

  def self.all(fields = [])
    find([], fields)
  end

  def self.find(ids = [], fields = [])
    ids = [ids].flatten.uniq
    args = {}
    args[:ids] = ids if ids.length > 0
    args[:fields] = (DEFAULT_FIELDS + fields).uniq
    data = client.action('torrent-get', args)
    data['torrents']
  end

  def self.set(args)
    args['ids'].flatten!.uniq! if args['ids']
    client.action('torrent-set', args)
  end

  def self.start(ids)
    ids_action('torrent-start', ids)
  end

  def self.start_now(ids)
    ids_action('torrent-start-now', ids)
  end

  def self.stop(ids)
    ids_action('torrent-stop', ids)
  end

  def self.verify(ids)
    ids_action('torrent-verify', ids)
  end

  def self.reannounce(ids)
    ids_action('torrent-reannounce', ids)
  end

  def self.add(filename, metainfo = nil, opts = {})
    args = {}
    args[:filename] = filename if filename
    args[:metainfo] = filename if metainfo
    opts.merge!(args)
    data = client.action('torrent-add', opts)
    if data['torrent-duplicate']
      fail ActionError("Torrent #{filename} already exists", 500)
    end
    data['torrent-added']
  end

  def self.remove(ids, hard_delete = false)
    ids_action(
      'torrent-remove',
      ids,
      'delete-local-data' => hard_delete
    )
  end

  def self.move(ids, location, move = false)
    ids_action(
      'torrent-set-location',
      ids,
      location: location,
      move: move
    )
  end

  def self.rename(ids, path, name)
    ids_action(
      'torrent-rename-path',
      ids,
      path: path,
      name: name
    )
  end

  def self.session_get
    client.action('session-get')
  end

  def self.session_set(args)
    client.action('session-set', args)
  end

  def self.session_stats
    client.action('session-stats')
  end

  def self.update_blocklist
    data = client.action('blocklist-update')
    data['blocklist-size']
  end

  def self.test_port
    data = client.action('port-test')
    data['port-is-open']
  end

  def self.close_session
    client.action('session-close')
  end

  def self.prioritize(ids, action)
    unless PRIORITIZATION_ACTIONS.include?(action)
      fail ActionError('Priorization actions are top, bottom, up and down', 400)
    end
    ids_action("queue-move-#{action}", ids)
  end

  def self.free_space(path)
    data = client.action('free-space', path: path)
    data['size-bytes']
  end
end
