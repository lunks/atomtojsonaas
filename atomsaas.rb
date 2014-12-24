require 'sinatra'
require 'open-uri'
require 'simple-rss'
require 'json'

get '/' do
  content_type "application/json;charset=UTF-8"
  result = []
  next_feed = request[:feed]
  fields = request[:fields].split(',').map(&:to_sym)
  loop do  
    feed = SimpleRSS.parse(open(next_feed))
    next_feed = feed.source.scan(/<link rel='next'.*?href='(.*?)'.*?>/).flatten
    result << feed.entries.map do |e| 
      Hash[e.map do |k,v| 
        next if !fields.empty? && !fields.include?(k)
        _v = v.class == String ? v.force_encoding('UTF-8') : v
        [k, _v]
      end]
    end
    if !next_feed.empty?
      next_feed = next_feed[0]
    else 
      break
    end
  end
  result.flatten.to_json
end
