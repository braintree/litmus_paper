class NeverAvailableDependency < LitmusPaper::Dependency::Base
  def available?
    super do
      false
    end
  end

  def to_s
    self.class.name
  end
end
