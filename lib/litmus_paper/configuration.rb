module LitmusPaper
  fields = [
    :port,
    :data_directory,
    :services,
    :cache_location,
    :cache_ttl
  ]
  class Configuration < Struct.new(*fields)
  end
end
