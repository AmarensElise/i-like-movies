class Rack::Attack
  # Throttle all requests by IP (60 requests per minute)
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Stricter throttle for actor pages (20 requests per minute per IP)
  throttle("actors/ip", limit: 20, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/actors")
  end

  # Return 429 Too Many Requests with a Retry-After header
  self.throttled_responder = lambda do |env|
    retry_after = (env["rack.attack.match_data"] || {})[:period]
    [
      429,
      { "Content-Type" => "text/plain", "Retry-After" => retry_after.to_s },
      ["Rate limit exceeded. Try again later.\n"]
    ]
  end
end
