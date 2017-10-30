require "jwt"

module AuthToken

  # More information on jwt available at
  # http://self-issued.info/docs/draft-ietf-oauth-json-web-token.html#rfc.section.4.1.6
  def self.issue_token(
    payload = {},
    exp = (Time.now + 86400),
    secret = nil,
    aud = nil
  )
    config = Senkyoshi.configuration
    payload["iat"] = Time.now.to_i # issued at claim
    payload["exp"] = exp.to_i # Default expiration set to 24 hours.
    payload["aud"] = aud || config.scorm_shared_id
    JWT.encode(
      payload,
      secret || config.scorm_shared_auth,
      "HS512",
    )
  end

  def self.valid?(token, secret = nil)
    config = Senkyoshi.configuration
    JWT.decode(token, secret || config.scorm_shared_auth)
  end
end
