require File.expand_path('../../spec_helper', __FILE__)

describe String do
  it 'should not do anything when there is no leading whitespace' do
    "abc\ndef\nhij".unindent.should == "abc\ndef\nhij"
  end

  it 'should remove leading whitespace consistently' do
    "  abc\n  def\n  hij".unindent.should == "abc\ndef\nhij"
  end

  it 'should remove no whitespace when one line has none' do
    "  abc\ndef\n  hij".unindent.should == "  abc\ndef\n  hij"
  end

  it 'should ignore blank lines' do
    "  abc\n  def\n\n  hij".unindent.should == "abc\ndef\n\nhij"
  end

  it 'should remove no more whitespace than required' do
    # Left-most at beginning.
    unindented = "  abc\n    def\n    hij\n    lmn".unindent
    unindented.should == "abc\n  def\n  hij\n  lmn"

    # Left-most in middle.
    unindented = "    abc\n    def\n  hij\n    lmn".unindent
    unindented.should == "  abc\n  def\nhij\n  lmn"

    # Left-most at end.
    unindented = "    abc\n    def\n    hij\n  lmn".unindent
    unindented.should == "  abc\n  def\n  hij\nlmn"
  end
end
