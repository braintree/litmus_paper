class StdoutLogger
  def write(message)
    puts message
  end

  alias info write
  alias debug write
end
