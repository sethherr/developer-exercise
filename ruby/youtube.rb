require 'json'
require 'uri'
require 'net/http'

class Youtube
  def search(str)
    query = URI.encode_www_form({
      part: 'snippet',
      q: str,
      safeSearch: 'none',
      fields: 'items',
      key: 'AIzaSyDFXNXAYTABusB9mecClQKZwSYZBRu2qUU'
    })
    uri = URI::HTTPS.build(host: 'www.googleapis.com', path: '/youtube/v3/search', query: query)
    parsed_response = JSON.parse(Net::HTTP.get_response(uri).body)
    return parsed_response unless parsed_response['items']
    parsed_response['items'].slice(0,3).map { |i| "https://www.youtube.com/watch?v=#{i['id']['videoId']}" }
  end
end
