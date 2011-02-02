shared_examples_for 'saving a sprite' do
  # Requires:
  #
  #   @sprite => Polymer::Sprite
  #   @dir    => Pathname (path at which the sprite is saved)
  #   @output => Pathname (path for the final sprite)
  #
  it 'should save the sprite to the specified directory' do
    lambda { @sprite.write }.should \
      change(&lambda { @output.file? })
  end

  it 'should overwrite an existing file' do
    FileUtils.touch(@output)
    orig_size = @output.size
    @sprite.write

    # Using touch should create an empty file. Saving the PNG
    # should result in a larger file.
    @output.should be_file
    @output.size.should > orig_size
  end
end
