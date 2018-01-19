


module Zapiclient



  class Config

    attr_accessor :baseUrl

    def self.getBaseUrl()
      return 'https://prod-api.zephyr4jiracloud.com/connect'
    end

    def self.serverinfo()
      'https://prod-api.zephyr4jiracloud.com/connect'
    end
  end



end