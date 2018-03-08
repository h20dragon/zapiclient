
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

if Zapiclient::Utils.instance.isUpdate?
  puts "Updating execution status .." if Zapiclient::Utils.instance.isVerbose?
  update(parms)
elsif Zapiclient::Utils.instance.isSearch?
  puts "ZQL Search: " + Zapiclient::Utils.instance.getZqlString() if Zapiclient::Utils.instance.isVerbose?
  client = Zapiclient::Client.new()
  client.zqlSearch(Zapiclient::Utils.instance.getZqlString())

elsif Zapiclient::Utils.instance.isUpdateTestStepStatus?
  puts "Update Test Step #{Zapiclient::Utils.instance.getStep()} Status" if Zapiclient::Utils.instance.isVerbose?

  project = {:project => 'Kinetica Playground Project', :cycleName => 'beta1', :testcase => 'KPP-54' }
  project = {:project => Zapiclient::Utils.instance.getProject(),
             :cycleName => Zapiclient::Utils.instance.getCycle(),
             :testcase  => Zapiclient::Utils.instance.getTestCase()
            }
  step = Zapiclient::Utils.instance.getStep() # 'test_add_big_point.test_add_big_point'
  status = Zapiclient::Utils.instance.getExecutionStatus()  # 'wip'
  comment = Zapiclient::Utils.instance.getComment() || Time.now().to_s + " - updated."

  client = Zapiclient::Client.new()
  client.updateCycleTestStepResult(project, step, status, comment)

elsif Zapiclient::Utils.instance.isCreateCycle?

  opts = {:project => Zapiclient::Utils.instance.getProject(),
          :cycleName => Zapiclient::Utils.instance.getCycle(),
          :release  => Zapiclient::Utils.instance.getRelease(),
          :build => Zapiclient::Utils.instance.getBuild(),
          :environment => Zapiclient::Utils.instance.getEnvironment(),
          :description => Zapiclient::Utils.instance.getDescription()
  }

  puts "== Create Cycle #{opts} =="
  client = Zapiclient::Client.new()
  client.createCycle(opts)

elsif Zapiclient::Utils.instance.isAddTestsToCycle?
  client = Zapiclient::Client.new()
  client.addTestToCycle()

elsif Zapiclient::Utils.instance.isFolder?
  client = Zapiclient::Client.new()

  opts = {:project => Zapiclient::Utils.instance.getProject(),
          :cycle => Zapiclient::Utils.instance.getCycle(),
          :release  => Zapiclient::Utils.instance.getRelease()
  }

  client.createTestFolder(opts)

elsif Zapiclient::Utils.instance.isFolders?
  client = Zapiclient::Client.new()

  opts = {:project => Zapiclient::Utils.instance.getProject(),
          :cycle => Zapiclient::Utils.instance.getCycle(),
          :release  => Zapiclient::Utils.instance.getRelease()
  }

  client.getFolders(opts)
elsif Zapiclient::Utils.instance.isResetCycle?
  client = Zapiclient::Client.new()
  opts = {:project => Zapiclient::Utils.instance.getProject(),
          :cycle => Zapiclient::Utils.instance.getCycle(),
          :release  => Zapiclient::Utils.instance.getRelease()
  }
  client.reset(opts)

elsif Zapiclient::Utils.instance.isReport?
  client = Zapiclient::Client.new()
  opts = {:project => Zapiclient::Utils.instance.getProject(),
          :cycle => Zapiclient::Utils.instance.getCycle(),
          :release  => Zapiclient::Utils.instance.getRelease()
  }
  client.getCycleExecutions(opts)

elsif Zapiclient::Utils.instance.isAddAttachment?

  parms = {
              :project => Zapiclient::Utils.instance.getProject(),
              :release => Zapiclient::Utils.instance.getRelease(),
              :cycle => Zapiclient::Utils.instance.getCycle(),
              :testcase => Zapiclient::Utils.instance.getTestCase(),
              :status => Zapiclient::Utils.instance.getExecutionStatus(),
              :file => Zapiclient::Utils.instance.getFile()
            }

  required_parms = [:file, :project, :release, :cycle, :testcase]
  required_parms.each do |r|
    if parms[r].nil?
      puts "#{r} is a required field"
      exit(1)
    end



  end

  puts "AddAttachment => #{parms}" if Zapiclient::Utils.instance.isVerbose?
  client = Zapiclient::Client.new()
  client.addAttachment(parms)

  if Zapiclient::Utils.instance.isValidStatus(parms[:status])
    puts "==> UPDATE STATUS== " if Zapiclient::Utils.instance.isVerbose?
    parms[:status]={:execution => Zapiclient::Utils.instance.getStatus()}
    update(parms)
  end
end

