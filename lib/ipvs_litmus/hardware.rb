module IPVSLitmus
  class Hardware
    def processor_count
      Facter.value('processorcount').to_i
    end

    def load
      Facter.value('loadaverage').split(' ').first.to_f
    end
  end
end
