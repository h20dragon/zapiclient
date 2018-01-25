
require_relative '../lib/zapiclient'


def update(parms)
  _project = parms[:project]
  _release = parms[:release]
  _cycle = parms[:cycle]
  _status = parms[:status][:execution]
  _testcase = parms[:testcase]

  # Verify parameters


  client = Zapiclient::Client.new()
  client.update(parms)
end


# ruby examples/drv.rb  --project "My Project" --release "My Release" --testcase "MyTestCase" --cycle "MyCycle" --status:execution PASS
parms = Zapiclient::Utils.instance.parseCommandLine()
update(parms)
