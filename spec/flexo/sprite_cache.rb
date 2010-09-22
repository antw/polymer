require 'spec_helper'

describe Flexo::Cache do
  subject { Flexo::Cache }

  before(:each) do
    @helper  = Flexo::Spec::ProjectHelper.go!
    @project = @helper.project
  end

  # --- stale? ---------------------------------------------------------------

  describe '#stale?' do
    context 'when given a sprite which does not exist on disk'
    context 'when given a sprite whose sources are unchanged'
    context 'when given a sprite with a deleted source'
    context 'when given a sprite with a new source'
    context 'when given a sprite with a changed source'
  end

end
