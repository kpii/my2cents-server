When /^background jobs are processed$/ do
  Delayed::Worker.new.work_off
end

When /^background workers are running$/ do
  @background_workers = []

  Delayed::Worker.sleep_delay = 1.second.to_i

  config = ActiveRecord::Base.remove_connection

  3.times do
    if pid = fork
      @background_workers << pid
    else
      ActiveRecord::Base.establish_connection(config)
      Delayed::Worker.new(:quiet => true).start
    end
  end
  ActiveRecord::Base.establish_connection(config)
end


After do
  unless @background_workers.blank?
    @background_workers.each do |pid|
      Process.kill("KILL", pid)
    end
    Process.wait
  end
end


#When /^background workers are running$/ do
#  #Delayed::Worker.sleep_delay = 1.second.to_i
#
#  puts "starting workers"
#  `cd #{Rails.root} && RAILS_ENV=#{Rails.env} script/delayed_job -n 3 start`
#  puts "done starting workers"
#
#  @started_workers = true
#end
#
#After do
#  if @started_workers
#    puts "stopping workers"
#    `pkill -f delayed_job`
#    @started_workers = false
#    puts "done stopping workers"
#  end
#end
