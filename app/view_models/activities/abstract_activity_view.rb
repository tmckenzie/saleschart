module Activities
  class AbstractActivityView
    MEDIA_TYPE_FACEBOOK = "facebook"
    MEDIA_TYPE_EMAIL = "email"
    MEDIA_TYPE_TWITTER = "twitter"
    MEDIA_TYPE_TEXT = "text"

    def media_message_for(media_type, encode_url = false)
      msg = send("#{media_type}_content")
      if msg.present?
        url = encode_url ? URI.encode_www_form_component(share_url) : share_url
        new_msg = msg.gsub(root_page_url, url)
        # Add url at the end for non fb media, only if no url substitution happened and only if there are no urls in the content
        if media_type != MEDIA_TYPE_FACEBOOK && new_msg == msg && new_msg !~ /http(s?):\/\//
          new_msg += " #{url}"
        end
        msg = new_msg
      end
      msg
    end

    def root_page_url
      raise NotImplementedError
    end

    def share_url
      raise NotImplementedError
    end
  end
end