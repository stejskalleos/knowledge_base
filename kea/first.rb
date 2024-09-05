require 'net/http'
require 'json'

class KeaClient
  def initialize
    @base_url = 'http://127.0.0.1:8000'
  end

  def request(endpoint, payload)
    uri = URI("#{@base_url}/#{endpoint}")
    req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    req.body = payload.to_json
    res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
    puts JSON.parse(res.body)
  end

  def allocate_lease(mac)
    payload = {
      command: "lease4-add",
      service: [ "dhcp4" ],
      arguments: {
        "hw-address": mac,
        "ip-address": '',
      }
    }
    request('lease4-add', payload)
  end

  def renew_lease(ip_address)
    payload = {
      command: "lease4-update",
      service: [ "dhcp4" ],
      arguments: {
        "ip-address": ip_address,
        "state": "renew"
      }
    }
    request('lease4-update', payload)
  end
  # Other methods: release_lease, get_lease, etc.
end

# Usage:
kea_client = KeaClient.new
kea_client.allocate_lease('AA:BB:CC:DD:EE:FF')
# kea_client.renew_lease('192.168.1.100')
