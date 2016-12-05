class AlwaysAvailableDependency < LitmusPaper::Dependency::Base
  def available?
    super do
      true
    end
  end

  def to_s
    self.class.name
  end
end
