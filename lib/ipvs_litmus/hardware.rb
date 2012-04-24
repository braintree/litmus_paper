module IPVSLitmus
  class Hardware
    MULTIPLIER = {
      "GB" => 1024*1024*1024,
      "MB" => 1024*1024,
      "KB" => 1024
    }

    def processor_count
      Facter.value('processorcount').to_i
    end

    def memory_total
      size, scale = Facter.value('memorytotal').split(' ')
      size.to_i * MULTIPLIER[scale]
    end

    def memory_free
      size, scale = Facter.value('memoryfree').split(' ')
      size.to_i * MULTIPLIER[scale]
    end

    def load
      Facter.value('loadaverage').split(' ').first.to_f
    end
  end
end
