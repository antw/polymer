v1.0.0 / HEAD (Unreleased)
--------------------------

* Montage has been renamed to Polymer and is now released under the BSD
  three-clause license.

* The Polymer configuration must now be located at the project root and
  should be named either ".polymer" or, for Windows users, "polymer.yml".
  You should rename your existing ".montage" file to ".polymer", and
  ".montage\_cache" should be changed to ".polymer-cache".

* The Polymer configuration file no longer uses YAML, but instead opts
  for a simple Ruby-based DSL. See `polymer help .polymer` for full
  documentation.

* The Sass mixin has changed slightly; instead of generating separate
  mixins for each of your sprites, all of your sprites are available
  using the global "polymer()" mixin. This should be called as such:

      .my_selector
        +polymer("sprite_name/source_name")

  Mixins still permit you to supply an optional x-offset and y-offset as
  the second and third parameters. the "polymer-position()" mixin is
  also available as an alternative to the old "sprite-name-pos()"
  mixins.

* Sprites can now be included "inline" in your Sass files by setting the
  sprite path to :data\_uri in your .polymer file. This further reduces
  the number of HTTP requests required at the expense of slightly
  greater data transfer.

  Polymer adds the data URI to the Sass file by using a selector (such
  as ".my\_sprite\_data"), and then uses Sass' @extend feature so that
  the data is only added to the CSS file once. Your own Sass files do
  not need to be modified to make use of this feature; the @polymer
  mixin suffices.

* The "polymer-pos" Sass mixin, which sets only the background position
  of a source, without including the background-image property, has been
  renamed to "polymer-position".

* The "generate" command is now "bond": `$ polymer bond`

* A new "position" command shows information about a source within a
  sprite, and provides useful CSS for use when building your own
  styleesheets.

* Documentation of each command is now available by running `polymer
  help` or `polymer help [COMMAND]`.

* The Polymer configuration no longer allows a "config.root" option and
  the library will not work correctly if this is present in your config
  file. Please move your ".polymer" file to your project root and remove
  this option.

* The library internals have been substantially changed with Thor now
  being used to handle all CLI commands.

* When creating a new Polymer project, you may suppress the copying of
  example sources by passing the --no-examples option.

* The polymer init command no longer uses Highline to prompt for your
  preferred paths to your source and output files. If you need to change
  the defaults you may instead use the --source and --sprites options.

* All CLI commands are now tested with Cucumber.

* Jeweler has been replaced with plain rake tasks inspired by Rakegem --
  [http://github.com/mojombo/rakegem](http://github.com/mojombo/rakegem).

v0.4.0 (18th August, 2010)
--------------------------

* You no longer need to specify a :name option in your sprite defintions
  when supplying a full output filename.

v0.3.0 (12th April, 2010)
-------------------------

* The "montage.yml" file has been replaced with ".montage" which should
  be located in your project root. In addition, the file is now rather
  different, and in most cases will never need to be edited when you
  want to add new sources to the sprite.

* By default Montage will now save sprites to public/images, expected
  source images to be in public/images/subdir -- where "subdir" will
  become the name of the sprite. All sources in a subdirectory will be
  added to the same sprite.

  This behavior is entirely customisable in the .montage file.

* The ".montage\_cache" file which was previously saved in the same
  directory as sprites is now saved in the project root.

* The `montage` command now allows you to specify a path to a Montage
  configuration file; for example `montage path/to/montage.yml`. When
  using a non-standard directory structure, you can specify a
  "config.root" option in the configuration file, containing the path to
  the project root.

v0.2.0 (8th April, 2010)
------------------------

* Running `montage` will now generate `_montage.sass` in the specified
  config.sass directory. A separate mixin will be generated for each
  sprite, with the mixin accepting three arguments: the name of the
  source image, an optional horizontal offset, and an optional vertical
  offset. Disable the Sass generation by setting config.sass to false.

* If pngout or pngout-darwin is available (run `which pngout
  pngout-darwin` to find out), Montage will compress the generated
  sprites. Installing pngout is strongly recommended; significant
  savings can be made on larger PNGs.

* The `montage` command accepts a '--force' option which will regenerate
  all sprites even if they haven't been changed since the last run.

* Sprites will be regenerated if the file has been deleted.

v0.1.2 (6th April, 2010)
------------------------

* Sprites will only be regenerated when their definition (in
  montage.yml) has changed, or if the contents of the source files have
  changed.

* The `montage init` command now uses the highline gem to ask for the
  paths to a project's source files, and the intended sprite output
  directory.

* Running `montage init` will copy some sample source files into the
  source directory. This allows running `montage` immediately after
  creating the project, to see how things work.

v0.1.1 (5th April, 2010)
------------------------

* Small fix for Ruby 1.9.1, which doesn't define String#inject.

v0.1.0 (5th April, 2010)
------------------------

* Initial release. Supports creation of sprites and not much else.
