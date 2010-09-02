require 'spec_helper'

describe 'have_public_method_defined matcher' do
  before(:all) do
    @exception = RSpec::Expectations::ExpectationNotMetError
  end

  describe 'with should' do
    it 'should pass when the method is defined' do
      running = lambda { String.should have_public_method_defined(:length) }
      running.should_not raise_error(@exception)
    end

    it 'should fail when the method is not defined' do
      running = lambda { String.should have_public_method_defined(:__invalid__) }
      running.should raise_error(@exception)
    end
  end

  describe 'with should_not' do
    it 'should fail when the method is defined' do
      running = lambda { String.should_not have_public_method_defined(:length) }
      running.should raise_error(@exception)
    end

    it 'should pass when the method is not defined' do
      running = lambda { String.should_not have_public_method_defined(:__invalid__) }
      running.should_not raise_error(@exception)
    end
  end
end
