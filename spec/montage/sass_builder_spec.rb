require File.expand_path('../../spec_helper', __FILE__)

describe Montage::SassBuilder do
  subject { Montage::SassBuilder }

  # --- write ----------------------------------------------------------------

  it { should have_public_method_defined(:write) }

  describe '#write' do
    before(:each) do
      @helper = Montage::Spec::ProjectHelper.new
    end

    context 'with a project containing a single sprite and two sources' do
      before(:each) do
        @helper.write_config <<-CONFIG
        ---
          only:
            - one
            - two
        CONFIG

        @helper.write_source('one')
        @helper.write_source('two')

        Montage::SassBuilder.new(@helper.project).write

        @sass_path = @helper.path_to_file(
          'public/stylesheets/sass/_montage.sass')

        if @sass_path.file?
          @sass = File.read(@helper.path_to_file(
            'public/stylesheets/sass/_montage.sass'))
        else
          @sass = 'MISSING SASS FILE'
        end
      end

      it 'should save the Sass file' do
        @sass_path.should be_file
      end

      it 'should contain the sprite mixin' do
        @sass.should =~ /^=only-sprite/
      end

      it 'should include a condition for the "one" source' do
        expected = Regexp.escape(
          %[  @if $icon == "one"\n] +
          %[    $y_offset: $y_offset - 0px])

        @sass.should =~ /^#{expected}/
      end

      it 'should include a condition for the "two" source' do
        expected = Regexp.escape(
          %[  @else if $icon == "two"\n] +
          %[    $y_offset: $y_offset - #{20 + @helper.project.padding}px])

        @sass.should =~ /^#{expected}/
      end

      it 'should include the background statement' do
        @sass.should include(
          "  background: url(/images/sprites/only.png)")
      end

      describe 'the generated mixins' do
        it 'should correctly position the first source' do
          sass = Sass::Engine.new(<<-SASS.unindent).render
            @import #{@helper.project.paths.sass.realpath + '_montage.sass'}

            .rule
              +only-sprite("one")
          SASS

          sass.should include(
            'background: url(/images/sprites/only.png) 0px 0px no-repeat')
        end

        it 'should correctly position the second source' do
          sass = Sass::Engine.new(<<-SASS.unindent).render
            @import #{@helper.project.paths.sass.realpath + '_montage.sass'}

            .rule
              +only-sprite("two")
          SASS

          sass.should include(
            'background: url(/images/sprites/only.png) 0px -40px no-repeat')
        end

        it 'should apply x-offsets' do
          sass = Sass::Engine.new(<<-SASS.unindent).render
            @import #{@helper.project.paths.sass.realpath + '_montage.sass'}

            .rule
              +only-sprite("one", 5px)
          SASS

          sass.should include(
            'background: url(/images/sprites/only.png) 5px 0px no-repeat')
        end

        it 'should apply y-offsets' do
          sass = Sass::Engine.new(<<-SASS.unindent).render
            @import #{@helper.project.paths.sass.realpath + '_montage.sass'}

            .rule
              +only-sprite("two", 0px, -10px)
          SASS

          # -20px (source one) - 20px (padding) - 10px (third arg) = -50px
          sass.should include(
            'background: url(/images/sprites/only.png) 0px -50px no-repeat')
        end
      end
    end # with a project containing a single sprite and two sources

    context 'with a project containing two sprites, each with two sources' do
      before(:each) do
        @helper.write_config <<-CONFIG
        ---
          first:
            - one
            - two

          second:
            - three
            - four
        CONFIG

        %w( one two three four ).each do |source|
          @helper.write_source(source)
        end

        Montage::SassBuilder.new(@helper.project).write

        @sass_path = @helper.path_to_file(
          'public/stylesheets/sass/_montage.sass')

        if @sass_path.file?
          @sass = File.read(@helper.path_to_file(
            'public/stylesheets/sass/_montage.sass'))
        else
          @sass = 'MISSING SASS FILE'
        end
      end

      it 'should save the Sass file' do
        @sass_path.should be_file
      end

      it 'should contain both sprite mixins' do
        @sass.should =~ /^=first-sprite/
        @sass.should =~ /^=second-sprite/
      end

      it 'should include a condition for the "one" source' do
        expected = Regexp.escape(
          %[  @if $icon == "one"\n] +
          %[    $y_offset: $y_offset - 0px])

        @sass.should =~ /^#{expected}/
      end

      it 'should include a condition for the "two" source' do
        expected = Regexp.escape(
          %[  @else if $icon == "two"\n] +
          %[    $y_offset: $y_offset - #{20 + @helper.project.padding}px])

        @sass.should =~ /^#{expected}/
      end

      it 'should include a condition for the "three" source' do
        expected = Regexp.escape(
          %[  @if $icon == "three"\n] +
          %[    $y_offset: $y_offset - 0px])

        @sass.should =~ /^#{expected}/
      end

      it 'should include a condition for the "four" source' do
        expected = Regexp.escape(
          %[  @else if $icon == "four"\n] +
          %[    $y_offset: $y_offset - #{20 + @helper.project.padding}px])

        @sass.should =~ /^#{expected}/
      end

      it 'should include the background statement for the first sprite' do
        @sass.should include(
          "  background: url(/images/sprites/first.png)")
      end

      it 'should include the background statement for the second sprite' do
        @sass.should include(
          "  background: url(/images/sprites/second.png)")
      end
    end # with a project containing two sprites, each with two sources

    context 'with a project using a custom SASS location' do
      before(:each) do
        @helper.write_config <<-CONFIG
        ---
          config.sass: "public/sass"

          only:
            - one
        CONFIG

        @helper.write_source('one')
        Montage::SassBuilder.new(@helper.project).write
      end

      it 'should save the Sass file' do
        @helper.path_to_file(
          'public/sass/_montage.sass').should be_file
      end
    end # with a project using a custom SASS location

    context 'with a project using a custom SASS location with a file name' do
      before(:each) do
        @helper.write_config <<-CONFIG
        ---
          config.sass: "public/sass/_here.sass"

          only:
            - one
        CONFIG

        @helper.write_source('one')
        Montage::SassBuilder.new(@helper.project).write
      end

      it 'should save the Sass file' do
        @helper.path_to_file(
          'public/sass/_here.sass').should be_file
      end
    end # with a project using a custom SASS location with a file name

    context 'with a project using a custom sprite_url setting' do
      before(:each) do
        @helper.write_config <<-CONFIG
        ---
          config.sprite_url: "/right/about/here"

          only:
            - one
        CONFIG

        @helper.write_source('one')

        Montage::SassBuilder.new(@helper.project).write

        @sass = File.read(@helper.path_to_file(
          'public/stylesheets/sass/_montage.sass'))
      end

      it 'should include the background statement' do
        @sass.should include(
          "  background: url(/right/about/here/only.png)")
      end
    end # with a project using a custom sprite_url setting

  end # build

end
