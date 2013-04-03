#!/usr/bin/env ruby

require 'rubygems'
require 'koala'
require 'exifr'
require 'xmp'
require 'yamler'

def load_yaml(path)
  return Yamler.load(File.join(File.dirname(File.expand_path(__FILE__)), path))
end

config  = load_yaml 'config.yml'
userids = load_yaml 'userid_mapping.yml'
graph   = Koala::Facebook::API.new(config['oauth_token'])

# create an album if one isn't specified
album_id = config['album_id']
if album_id.nil? do
  STDOUT.write "Creating an album... "
  resp = graph.put_object('me', 'albums', {:name => 'Japan'})
  album_id = resp['id']
  STDOUT.puts (album_id.nil? ? "failed!" : album_id)
else
  puts "Using album id: #{album_id}"
end

# Find all jpgs in the folder
pics = Dir[config['photos_dir'].sub(/\/$/, '') + '/*.jpg']
pics.each do |pic|
  puts "Processing #{pic}"
  exif =  XMP.parse(EXIFR::JPEG.new(pic)).dc
  tags =  exif.subject
  title = exif.respond_to? 'title' ? exif.title : ''
  caption = exif.respond_to? 'caption' ? exif.caption : ''
  message = [title, caption].join("\n").strip

  puts "=> Found tags: #{tags.join ', '}"
  id_tags = userids.select {|k,v| tags.include? k}
  puts "=> Matching user ids: #{id_tags.keys}"

  # upload the picture
  STDOUT.write "Uploading picture... "
  
  resp = graph.put_picture(pic, {:message => message}, album_id)
  photo_id = resp['id']
  STDOUT.puts photo_id.nil? ? "failed!" : photo_id
  
  # tag the picture
  # https://developers.facebook.com/docs/reference/api/photo/, tags#create
  STDOUT.write "Tagging picture... "
  tag_params = Hash[id_tags.map {|k,v| ['tag_uid', v]}]
  resp = graph.put_object(photo_id, 'tags', tag_params)
  STDOUT.puts resp ? "Success!" : "Failed!"

  puts "\n"
end
exit

class Object
  def or_if(method, val = nil)
    self.send(method) ? (block_given? ? yield : val) : self
  end         
end


# reading tags
# https://github.com/arsduo/koala/wiki
# https://developers.facebook.com/docs/reference/api/photo/


# http://rdoc.info/github/remvee/exifr
# http://rubydoc.info/gems/xmp/0.2.0/frames
img = EXIFR::JPEG.new(filename)
xmp = XMP.parse(img)
xmp.dc.subject # tags
