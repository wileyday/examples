require 'openssl'
require 'Base64'
require 'net/http'
require 'json'
require 'securerandom'

#
# solapi ruby
# send group message
#

file = File.read '../config.json'
$config = JSON.parse(file)

def get_header
    apiKey = $config["apiKey"]
    apiSecret = $config["apiSecret"]
    date = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%L%z')
    salt = SecureRandom.hex
    signature = OpenSSL::HMAC.hexdigest('SHA256', apiSecret, date + salt)
    return 'HMAC-SHA256 apiKey=' + apiKey + ', date=' + date + ', salt=' + salt + ', signature=' + signature
end

def create_group
    header = get_header
    # puts 'header : ' + header
    uri = URI('https://api.solapi.com/messages/v4/groups')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
    req.add_field('Authorization', header)
    res = http.request(req)
    # puts res.body
    group_id = JSON.parse(res.body)["groupId"]
    return group_id
rescue => e
    puts 'failed'
    puts e
end

groupId = create_group()
puts 'groupId: ' + groupId
