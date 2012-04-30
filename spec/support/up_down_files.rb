RSpec.configure do |config|
  config.before(:each) do
    FileUtils.rm_rf(IPVSLitmus.config_dir)
  end
end

def write_global_up_file(message)
  FileUtils.mkdir_p IPVSLitmus.config_dir
  File.open(IPVSLitmus.config_dir.join('global_up'), 'w') do |file|
    file.puts message
  end
end

def write_global_down_file(message)
  FileUtils.mkdir_p IPVSLitmus.config_dir
  File.open(IPVSLitmus.config_dir.join('global_down'), 'w') do |file|
    file.puts message
  end
end

def write_down_file(service_name, message)
  FileUtils.mkdir_p IPVSLitmus.config_dir.join('down')
  File.open(IPVSLitmus.config_dir.join('down', service_name), 'w') do |file|
    file.puts message
  end
end

def write_up_file(service_name, message)
  FileUtils.mkdir_p IPVSLitmus.config_dir.join('up')
  File.open(IPVSLitmus.config_dir.join('up', service_name), 'w') do |file|
    file.puts message
  end
end
