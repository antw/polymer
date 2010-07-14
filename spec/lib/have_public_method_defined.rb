::RSpec::Matchers.define :have_public_method_defined do |value|
  match do |klass|
    klass.public_method_defined?(value.to_sym)
  end

  description do
    "should define public instance method ##{value.to_s}"
  end

  failure_message_for_should do |klass|
    "expected #{klass.inspect} to define public instance method " \
    "#{value.inspect}, but it didn't"
  end

  failure_message_for_should_not do |klass|
    "expected #{klass.inspect} to not define public instance method " \
    "#{value.inspect}, but it did"
  end
end
