Spec::Runner.configure do |config|
  config.include(Module.new do
    def fixture_path(name, *segments)
      File.join(File.expand_path("../../fixtures/#{name}", __FILE__), *segments)
    end
  end)
end
