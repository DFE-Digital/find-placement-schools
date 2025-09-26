OkComputer.mount_at = "healthcheck"

class CurrentEnvCheck < OkComputer::Check
  def check
    mark_message ENV["RAILS_ENV"]
    true
  end
end

OkComputer::Registry.register "database", OkComputer::ActiveRecordCheck.new
OkComputer::Registry.register "sha", OkComputer::AppVersionCheck.new
OkComputer::Registry.register "current_env", CurrentEnvCheck.new
