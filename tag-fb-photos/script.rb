#!/usr/bin/env ruby

require 'rubygems'
require 'koala'
require 'exifr'
require 'yaml'

@config = YAML.load_file(File.join(File.dirname(File.expand_path(__FILE__)),"config.yml")) unless defined? CONFIG
graph = Koala::Facebook::API.new(@config[oauth_token])

# reading tags
# https://github.com/arsduo/koala/wiki
# https://developers.facebook.com/docs/reference/api/photo/
resp = graph.put_object('me/albums', {:name => 'Japan'})
album_id = resp.id
resp = graph.put_picture(filename, {:title => 'blah'})
photo_id = resp.id
graph.put_object(photo_id, {:to => user_id})

# http://rdoc.info/github/remvee/exifr
# http://rubydoc.info/gems/xmp/0.2.0/frames
img = EXIFR::JPEG.new(filename)
xmp = XMP.parse(img)
xmp.dc.subject # tags
