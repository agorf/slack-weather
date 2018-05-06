require_relative 'message_composer'
require 'dotenv/load'
require 'json'
require 'net/http'
require 'uri'

module SlackWeather
  class SlackPoster
    WEBHOOK_URL = ENV.fetch('WEBHOOK_URL').freeze

    def self.post(message)
      payload = JSON.generate(text: message)
      Net::HTTP.post_form(URI(WEBHOOK_URL), payload: payload)
    end
  end

  SlackPoster.post(MessageComposer.message)
end
