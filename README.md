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

Don't forget to execute :

```bash
$ bundle
```

## Usage

We need to setup `amplitude` before we can use it, Let’s do this in an initializer
Add the following to `config/initializers/amplitude.rb`:

```ruby
Amplitude.configure do |config|
  config.username = ENV['TRANSMISSION_USERNAME']
  config.password = ENV['TRANSMISSION_PASSWORD']
  config.url = 'http://127.0.0.1:9091/transmission/rpc' # your transmission rpc endpoint.
  config.debug = true # (optional) will enable full http traces.
end
```

We’re pulling these keys out of environmental variables so as not to hardcode them.

Now, we can retrieve all running torrents:

```ruby
torrents = Amplitude.all
```

__Notes:__ You can always debug requests by turning the `debug` options to `true` in configurations.

By default `all` only returns `id`, `name` and `totalSize` properties.
You can always get additional properties, here is a list of [available fields](https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt#L148).

```ruby
torrents = Amplitude.all(['rateDownload', 'rateUpload'])
```

Finding a specific torrent is also possible:

```ruby
torrents = Amplitude.find(42)
torrents = Amplitude.find(42, ['rateDownload', 'rateUpload'])
```

## Operations

### Add a new torrent

Adding a torrent using its magnet or standard url :

```ruby
Amplitude.add('http://website.tld/source.torrent')
```

Otherwise, you can put base64 content of the torrent file as a second argument:

```ruby
Amplitude.add(nil, base64_content)
```

Extra options can be set as a third argument. Please read the [spec](https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt#L362) for that.

### Remove existing torrent


```ruby
Amplitude.remove(id)
```

By default, local data are not deleted. If you want that simply add a `true` flag to the `remove` operation:

```ruby
Amplitude.remove(id, true)
```

### Starting or stopping a torrent

```ruby
Amplitude.start(id)
Amplitude.start_now(id)
Amplitude.stop(id)
```

### Setting properties using mutators


```ruby
Amplitude.set('uploadLimit', 3600)
```

Mutators properties are available in [spec](https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt#L96).

### Reading properties using accessors


```ruby
Amplitude.get('uploadLimit')
```

Accessors properties are available in [spec](https://trac.transmissionbt.com/browser/trunk/extras/rpc-spec.txt#L150).

### Executing a torrent verification

```ruby
Amplitude.verify(id)
```

### Asking tracker for more peer

```ruby
Amplitude.reannounce(id)
```

## Development & Contribution

Test cases can be run with :

```bash
$ bundle exec rake
```

* If you’re creating a small fix or patch to an existing feature, just a simple test will do.
* Please follow this [Ruby style-guide](https://github.com/bbatsov/ruby-style-guide) when modifying code.
* Contributions will not be (of course) accepted without tests.


