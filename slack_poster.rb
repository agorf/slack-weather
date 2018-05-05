require_relative './message_composer'
require 'dotenv/load'
require 'json'
require 'net/http'
require 'uri'

module SlackWeather
  class SlackPoster
    def self.post(message)
      payload = JSON.generate(text: message)
      Net::HTTP.post_form(URI(ENV.fetch('WEBHOOK_URL')), payload: payload)
    end
  end

  SlackPoster.post(MessageComposer.message)
end

