class UserSession < ActiveRecord::Base

  belongs_to :user

  class << self
    def session_from(token)
      session = self.find_by_session_token(token)
      if session && !expired?
        session.update_attributes(expire_at: Time.now)
      end
      session
    end

    def session_for(user)
      user_session = self.find_by_user_id(user.id)
      expire_dt = 1.day.from_now

      # Generate an authentication_token for any user that needs a session because if their
      # authentication_token is nil then it's highly possible to get multiple users with the same
      # session key which is bad.
      user.generate_api_token if user.authentication_token.nil?
      session_token = self.generate_token(user.authentication_token, expire_dt)

      if user_session.nil?
        user_session = self.create(user: user, session_token: session_token, expire_at: expire_dt)
      elsif user_session.expired?
        user_session.update_attributes(session_token: session_token, expire_at: expire_dt)
      end

      user_session
    end

    # This requires non-nil parameters so that we don't generate duplicate tokens
    def generate_token(auth_token, expire_dt)
      return "Authentication token required" if auth_token.nil?
      return "Expiration date required" if expire_dt.nil?
      Digest::SHA1.hexdigest([expire_dt, auth_token].join)
    end

    # This requires non-nil parameters so that we don't generate duplicate tokens
    def generate_public_token(auth_token)
      return "Authentication token required" if auth_token.nil?
      expire_dt = 1.year.from_now
      Digest::SHA1.hexdigest([expire_dt, auth_token].join)
    end

    def find_or_generate_session_token_by_auth_key(token, type = User::SESSION_AUTH_TOKEN_TYPE)
      return nil if token.nil?
      if type == User::PUBLIC_AUTH_TOKEN_TYPE
        user = User.find_by_public_auth_token(token)
      else
        user = User.find_by_authentication_token(token)
      end
      if user
        session = self.session_for(user)
      end
      session
    end
  end

  def expired?
    self.expire_at <= Time.now
  end

  def session_expires_at
    return nil if self.expire_at.nil?
    "#{DateTimeFormatter.new(self.expire_at.in_time_zone(user.time_zone)).display_default_with_meridian} #{user.time_zone}"
  end

  def session_expires_at_unix
    return nil if self.expire_at.nil?
    self.expire_at.to_i.to_s
  end
end