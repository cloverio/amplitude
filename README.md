# amplitude
Transmission RPC API Ruby Bindings

[![Build Status](https://travis-ci.org/cloverio/amplitude.svg)](https://travis-ci.org/cloverio/amplitude)
[![Code Climate](https://codeclimate.com/github/cloverio/amplitude.png)](https://codeclimate.com/github/cloverio/amplitude)
[![Coverage](https://codeclimate.com/github/cloverio/amplitude/coverage.png)](https://codeclimate.com/github/cloverio/amplitude)
[![Dependency Status](https://gemnasium.com/cloverio/amplitude.svg)](https://gemnasium.com/cloverio/amplitude)

> Because every transmission has its signal and amplitude.

## Requirements
* Ruby 2.0.0 or above.
* Transmission 2.80 or above.

## Installation
Add this line to your project’s Gemfile:

```ruby
gem 'amplitude'
```

## Configuration

```ruby
Amplitude.configure do |config|
  config.username = ENV['TRANSMISSION_USERNAME']
  config.password = ENV['TRANSMISSION_PASSWORD']
  config.url = 'http://127.0.0.1:9091/transmission/rpc' # your transmission rpc endpoint.
  config.debug = true # will enable full http traces.
end
```

## Usage

### All

Retrieve all torrents.

```ruby
torrents = Amplitude.all
```
You can specify the fields to return:

```ruby
torrents = Amplitude.all(['rateDownload', 'rateUpload'])
```
They will be added to default fields: `id`, `name` and `totalSize`.
Available fields : (https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt#L148)

### Find

Find torrents by `id`.

```ruby
torrents = Amplitude.find(42)
torrents = Amplitude.find(42, ['rateDownload', 'rateUpload'])
torrents = Amplitude.find([42, 43], ['rateDownload', 'rateUpload'])
```

### Add

Add torrent (one by one only).
Returns the added torrent.

```ruby
Amplitude.add('http://website.tld/file.torrent')
```

This also can be a magnet link.

Otherwise, you can put base64 content of the torrent file as the second argument:

```ruby
Amplitude.add(nil, base64_content)
```

Extra options can be set as 3rd argument. See RPC-Spec.

### Remove

Delete a torrent.

```ruby
Amplitude.remove(42)
Amplitude.remove([42, 43])
```

By default, datas are not deleted. If you want to:

```ruby
Amplitude.remove(42, true)
```

### Others

Others methods are available. Read amplitude.rb, it's pretty simple!
