require File.expand_path('../../spec_helper', __FILE__)

describe Flexo::SassBuilder do
  subject { Flexo::SassBuilder }

  # --- write ----------------------------------------------------------------

  it { should have_public_method_defined(:write) }

  describe '#write' do
    before(:each) do
      @helper = Flexo::Spec::ProjectHelper.new
    end

    context 'with a project containing a single sprite and two sources' do
      before(:each) do
        @helper.write_simple_config
        @helper.write_source('only/one')
        @helper.write_source('only/two')

        Flexo::SassBuilder.new(@helper.project).write

        @sass_path = @helper.path_to_file(
          'public/stylesheets/sass/_flexo.sass')

        if @sass_path.file?
          @sass = File.read(@helper.path_to_file(
            'public/stylesheets/sass/_flexo.sass'))
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
          "  background: url(/images/only.png)")
      end

      describe 'the generated mixins' do
        it 'should correctly position the first source' do
          sass = Sass::Engine.new(<<-SASS.unindent).render
            @import #{@helper.project.paths.sass.realpath + '_flexo.sass'}

            .rule
              +only-sprite("one")
          SASS

          sass.should include(
            'background: url(/images/only.png) 0px 0px no-repeat')
        end

        it 'should correctly position the second source' do
          sass = Sass::Engine.new(<<-SASS.unindent).render
            @import #{@helper.project.paths.sass.realpath + '_flexo.sass'}

            .rule
              +only-sprite("two")
          SASS

          sass.should include(
            'background: url(/images/only.png) 0px -40px no-repeat')
        end

        it 'should apply x-offsets' do
          sass = Sass::Engine.new(<<-SASS.unindent).render
            @import #{@helper.project.paths.sass.realpath + '_flexo.sass'}

            .rule
              +only-sprite("one", 5px)
          SASS

          sass.should include(
            'background: url(/images/only.png) 5px 0px no-repeat')
        end

        it 'should apply y-offsets' do
          sass = Sass::Engine.new(<<-SASS.unindent).render
            @import #{@helper.project.paths.sass.realpath + '_flexo.sass'}

            .rule
              +only-sprite("two", 0px, -10px)
          SASS

          # -20px (source one) - 20px (padding) - 10px (third arg) = -50px
          sass.should include(
            'background: url(/images/only.png) 0px -50px no-repeat')
        end
      end
    end # with a project containing a single sprite and two sources

    context 'with a project containing two sprites, each with two sources' do
      before(:each) do
        @helper.write_simple_config

        %w( first/one first/two second/three second/four ).each do |source|
          @helper.write_source(source)
        end

        Flexo::SassBuilder.new(@helper.project).write

        @sass_path = @helper.path_to_file(
          'public/stylesheets/sass/_flexo.sass')

        if @sass_path.file?
          @sass = File.read(@helper.path_to_file(
            'public/stylesheets/sass/_flexo.sass'))
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

      it 'should include a condition for the first sprite sources' do
        expected = Regexp.escape(
          %[  @if $icon == "one"\n] +
          %[    $y_offset: $y_offset - 0px\n] +
          %[  @else if $icon == "two"\n] +
          %[    $y_offset: $y_offset - #{20 + @helper.project.padding}px])

        @sass.should =~ /^#{expected}/
      end

      it 'should include a condition for the second sprite sources' do
        expected = Regexp.escape(
          %[  @if $icon == "four"\n] +
          %[    $y_offset: $y_offset - 0px\n] +
          %[  @else if $icon == "three"\n] +
          %[    $y_offset: $y_offset - #{20 + @helper.project.padding}px])

        @sass.should =~ /^#{expected}/
      end

      it 'should include the background statement for the first sprite' do
        @sass.should include(
          "  background: url(/images/first.png)")
      end

      it 'should include the background statement for the second sprite' do
        @sass.should include(
          "  background: url(/images/second.png)")
      end
    end # with a project containing two sprites, each with two sources

    context 'with a project using a custom SASS location' do
      before(:each) do
        @helper.write_config <<-CONFIG
        ---
          config.sass: "public/sass"

          "public/images/sprites/:name/*.{png,jpg,jpeg,gif}":
            to: "public/images/:name.png"

        CONFIG

        @helper.write_source('only/one')
        Flexo::SassBuilder.new(@helper.project).write
      end

      it 'should save the Sass file' do
        @helper.path_to_file(
          'public/sass/_flexo.sass').should be_file
      end
    end # with a project using a custom SASS location

    context 'with a project using a custom SASS location with a file name' do
      before(:each) do
        @helper.write_config <<-CONFIG
        ---
          config.sass: "public/sass/_here.sass"

          "public/images/sprites/:name/*.{png,jpg,jpeg,gif}":
            to: "public/images/:name.png"

        CONFIG

        @helper.write_source('only/one')
        Flexo::SassBuilder.new(@helper.project).write
      end

      it 'should save the Sass file' do
        @helper.path_to_file(
          'public/sass/_here.sass').should be_file
      end
    end # with a project using a custom SASS location with a file name

    context 'with a project using a custom url setting' do
      before(:each) do
        @helper.write_config <<-CONFIG
        ---
          config.url: "/right/about/here/:name.png"

          "public/images/sprites/:name/*.{png,jpg,jpeg,gif}":
            to: "public/images/:name.png"

        CONFIG

        @helper.write_source('only/one')

        Flexo::SassBuilder.new(@helper.project).write

        @sass = File.read(@helper.path_to_file(
          'public/stylesheets/sass/_flexo.sass'))
      end

      it 'should include the background statement' do
        @sass.should include(
          "  background: url(/right/about/here/only.png)")
      end
    end # with a project using a custom url setting

  end # build

end
