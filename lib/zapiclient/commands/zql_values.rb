

require 'json'
require_relative './command'

module Zapiclient::Commands

  class ZqlValues < Command

    BASE_URL = '/public/rest/api/1.0/zql/fields/values'

    def initialize()
      super(BASE_URL)
      @debug = true
      puts __FILE__ + (__LINE__).to_s + " [ZqlValues.init]" if @debug
    end


    def sendRequest()
      puts __FILE__ + (__LINE__).to_s + " [ZqlValues.sendRequest]: " if @debug

      @jwt = jwt()

      headers = {
          :content_type => 'application/json',
          :authorization => @jwt,
          :zapiaccesskey => getAccessKey()
      }

      @response = RestClient.get getFullUrl, headers

      parsed = JSON.parse(@response)

      return parsed
    end


    def execute()
      puts __FILE__ + (__LINE__).to_s + " [ZqlValues.execute]" if @debug
      @response = sendRequest()

      puts JSON.pretty_generate @response if @debug
      @response
    end

    def dump()
      puts JSON.pretty_generate @response
    end

    # id, key, name
    def getProject(p)

      puts __FILE__ + (__LINE__).to_s + " ZqlValues.getProject(#{p})" if @debug
      @projects = @response['fields']['project'].select { |project| project['name'].to_s == p}

      project = @projects[0]

      versions = @response['fields']['fixVersion'].select { |release| release['projectId'] == project['id']}

      return  { :info => project, :fixVersions => versions }
    end

    def getProjectVersions(projectName)
      project = getProject(projectName)
      fixVersions = @response['fields']['fixVersion'].select { |fixVersion| fixVersion['projectId'].to_s == project['id'].to_s }
    end

  end


end