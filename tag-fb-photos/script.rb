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

# login to Facebook Graph
graph = Koala::Facebook::API.new(config['oauth_token'])
=begin
request_token = true
graph = Koala::Facebook::API.new(config['oauth_token'])
begin
  graph.get_object 'me'
  request_token = false
rescue Exception => e
  STDERR.puts "Oauth_token invalid: #{e}"
end

if request_token
  if config['appId'].nil? or config['appSecret'].nil? or config['callbackUrl'].nil?
    raise 'app id/secret/callback undefined'
  end

  oauth = Koala::Facebook::OAuth.new(config['appId'], config['appSecret'], config['callbackUrl'])
  puts "Please login to facebook: #{oauth.url_for_oauth_code}"
  STDOUT.write "Paste the oauth token: "
  graph = Koala::Facebook::API.new(gets.chomp)
end
=end

# create an album if one isn't specified
album_id = config['album_id']
if album_id.nil? or album_id.strip.empty?
  STDOUT.write "Creating an album... "
  resp = graph.put_object('me', 'albums', {:name => 'Japan', :privacy => "{'value':'SELF'}"})
  album_id = resp['id']
  STDOUT.puts (album_id.nil? ? "Failed!" : "Success!\n=> Album id: #{album_id}")
else
  puts "Using album id: #{album_id}"
end

# ask for oauth token if one isn't defined
graph   = Koala::Facebook::API.new(config['oauth_token'])
if config['oauth_token'].nil?
  oauth = Koala::Facebook::OAuth.new(config['appId'], config['appSecret'], config['callbackUrl'])
end

# Find all jpgs in the folder
pics = Dir[config['photos_dir'].sub(/\/$/, '') + '/*.jpg']
pics.each do |pic|
  puts "\nProcessing #{pic}"
  exif = EXIFR::JPEG.new(pic)
  xmp = XMP.parse(exif)

  # gps info
  has_gps = exif.gps.nil? ? false : true
  loc = {}
  if has_gps
    lat = exif.gps.latitude
    lng = exif.gps.longitude
    if lat.finite? and lng.finite?
      puts "=> Found location info: [#{lat}, #{lng}]"
      loc = {'latitude' => lat, 'longitude' => lng}
    end
  end

  # tag info
  has_tags = ! xmp.nil?
  message = ''
  if has_tags
    tags    = xmp.dc.respond_to?('subject') ? xmp.dc.subject : []
    title   = xmp.dc.respond_to?('title')   ? xmp.dc.title : ''
    caption = xmp.dc.respond_to?('caption') ? xmp.dc.caption : ''

    puts "=> Found tags: #{tags.join ', '}" unless tags.nil?
    id_tags = userids.select {|k,v| tags.include? k}
    other_tags = tags.reject {|k,v| userids.include? k}
    puts "=> Matching user ids: #{id_tags.keys.join ', '}"

    has_tags = false if id_tags.empty?
    tag_str = other_tags.empty? ? '' : "\ntags: #{other_tags.join(', ')}"
    message = [title, caption, tag_str].join("\n").strip
  end

  # upload the picture
  5.times do
    begin
      STDOUT.write "Uploading picture... "
      resp = graph.put_picture(pic, {:message => message, :location => loc}, album_id)
      break
    rescue
      STDOUT.puts "Failed!"
    end
  end
  photo_id = resp['id']
  STDOUT.puts (photo_id.nil? ? "Failed!" : "Success!\n=> Picture id: #{photo_id}")
  
  # tag the picture
  # https://developers.facebook.com/docs/reference/api/photo/, tags#create
  if has_tags
    STDOUT.write "Tagging picture... "
    tag_params = id_tags.map {|k,v| {'tag_uid' => v}}
    resp = graph.put_connections(photo_id, 'tags', :tags => tag_params.to_json)
    STDOUT.puts resp ? "Success!" : "Failed!"
  else
    puts "No tags found in the picture.. Skipping tagging process"
  end
end
exit

# deprecated stuff

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
