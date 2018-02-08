module LitmusPaper
  class Util
    def self.symbolize_keys(hash)
      hash.keys.each do |k|
        new_key = (k.to_sym rescue k.to_s.to_sym)
        hash[new_key] = hash.delete(k)
      end

      hash
    end
  end
end
