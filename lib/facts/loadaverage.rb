Facter.add("loadaverage") do
  setcode do
    uptime = Facter::Util::Resolution.exec("uptime")
    uptime.split(":").last
  end
end
