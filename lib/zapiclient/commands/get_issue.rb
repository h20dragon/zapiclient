
require 'json'
require_relative './command'

module Zapiclient::Commands

  # {
  #     "searchObjectList": [
  #         {
  #             "warningMessage": null,
  #             "originMessage": null,
  #             "execution": {
  #                 "id": "0001517402203431-242ac112-0001",
  #                 "issueId": 45699,
  #                 "versionId": 13153,
  #                 "projectId": 13308,
  #                 "cycleId": "0001516461113601-242ac112-0001",
  #                 "orderId": 1,
  #                 "comment": "Tested on http://172.30.70.2 x86 1-P4",
  #                 "executedBy": "pkim",
  #                 "executedOn": "01-31-2018 07:54:20",
  #                 "modifiedBy": "pkim",
  #                 "createdBy": "pkim",
  #                 "status": {
  #                     "name": "FAIL",
  #                     "id": 2,
  #                     "description": "Test was executed and failed.",
  #                     "color": "#CC3300",
  #                     "type": 0
  #                 },
  #                 "cycleName": "beta1",
  #                 "assignedTo": "pkim",
  #                 "defects": [
  #
  #                 ],
  #                 "stepDefects": [
  #
  #                 ],
  #                 "executionDefectCount": 0,
  #                 "stepDefectCount": 0,
  #                 "totalDefectCount": 0,
  #                 "creationDate": "01-31-2018 07:36:43",
  #                 "executedByZapi": true,
  #                 "assignedOn": "01-31-2018 07:36:43",
  #                 "issueIndex": 45699,
  #                 "projectCycleVersionIndex": "13308_0001516461113601-242ac112-0001_13153",
  #                 "executionStatusIndex": 2,
  #                 "projectIssueCycleVersionIndex": "13308_45699_0001516461113601-242ac112-0001_13153"
  #             },
  #             "issueKey": "KPP-54",
  #             "issueLabel": "",
  #             "component": "QE",
  #             "issueSummary": "Alltest successfully tested on x86 with 1 P4",
  #             "issueDescription": null,
  #             "projectName": "Kinetica Playground Project",
  #             "versionName": "Release CORE 6.2",
  #             "priority": "Major",
  #             "priorityIconUrl": null,
  #             "executedByDisplayName": "Peter Kim",
  #             "assigneeType": null,
  #             "assignedToDisplayName": "Peter Kim",
  #             "testStepBeans": null,
  #             "defectsAsString": "",
  #             "projectKey": "KPP"
  #         }
  #     ],
  #     "summaryList": null,
  #     "totalCount": 1,
  #     "currentOffset": 1,
  #     "maxAllowed": 0,
  #     "sortBy": null,
  #     "sortOrder": null,
  #     "executionStatus": {
  #         "-1": {
  #             "name": "UNEXECUTED",
  #             "id": -1,
  #             "description": "The test has not yet been executed.",
  #             "color": "#A0A0A0",
  #             "type": 0
  #         },
  #         "1": {
  #             "name": "PASS",
  #             "id": 1,
  #             "description": "Test was executed and passed successfully.",
  #             "color": "#75B000",
  #             "type": 0
  #         },
  #         "2": {
  #             "name": "FAIL",
  #             "id": 2,
  #             "description": "Test was executed and failed.",
  #             "color": "#CC3300",
  #             "type": 0
  #         },
  #         "3": {
  #             "name": "WIP",
  #             "id": 3,
  #             "description": "Test execution is a work-in-progress.",
  #             "color": "#F2B000",
  #             "type": 0
  #         },
  #         "4": {
  #             "name": "BLOCKED",
  #             "id": 4,
  #             "description": "The test execution of this test was blocked for some reason.",
  #             "color": "#6693B0",
  #             "type": 0
  #         }
  #     },
  #     "stepExecutionStatus": {
  #         "-1": {
  #             "name": "UNEXECUTED",
  #             "id": -1,
  #             "description": "The test has not yet been executed.",
  #             "color": "#A0A0A0",
  #             "type": 0
  #         },
  #         "1": {
  #             "name": "PASS",
  #             "id": 1,
  #             "description": "Test was executed and passed successfully.",
  #             "color": "#75B000",
  #             "type": 0
  #         },
  #         "2": {
  #             "name": "FAIL",
  #             "id": 2,
  #             "description": "Test was executed and failed.",
  #             "color": "#CC3300",
  #             "type": 0
  #         },
  #         "3": {
  #             "name": "WIP",
  #             "id": 3,
  #             "description": "Test execution is a work-in-progress.",
  #             "color": "#F2B000",
  #             "type": 0
  #         },
  #         "4": {
  #             "name": "BLOCKED",
  #             "id": 4,
  #             "description": "The test execution of this test was blocked for some reason.",
  #             "color": "#6693B0",
  #             "type": 0
  #         }
  #     }
  # }

  class GetIssue < Command

    BASE_URL = '/public/rest/api/1.0/teststep/{ISSUE_ID}?projectId={PROJECT_ID}'

    def initialize()
      @debug = Zapiclient::Utils.instance.isVerbose?
      @searchFor = "project=\"{PROJECT_ID}\" and issue=\"{ISSUE_ID}\"" #" and cycleName=\"{CYCLE_NAME}\""
    end


    def execute(args)
      _project = args[:project]
      _issue   = args[:issue]  if args.has_key?(:issue)
      _issue   = args[:testcase] if args.has_key?(:testcase)

      puts __FILE__ + (__LINE__).to_s + " [GetIssue.execute]: #{_project}, #{_issue}" if Zapiclient::Utils.instance.isVerbose?

      tmpStr = @searchFor.sub('{PROJECT_ID}', _project)
      tmpStr = tmpStr.sub('{ISSUE_ID}', _issue)

      if args.has_key?(:cycleName)
        tmpStr = tmpStr + " and cycleName=\"#{args[:cycleName]}\""
      end

      _c = Zapiclient::Commands::ZqlSearch.new()
      _c.searchUsing(tmpStr)
      @response = _c.execute()

      if Zapiclient::Utils.instance.isVerbose?
        puts __FILE__ +  (__LINE__).to_s + " [GetIssue.execute]:"
        puts JSON.pretty_generate @response
      end

      return @response
    end

  end


end
