v0.1.2 - 2010-04-06
-------------------

* Sprites will only be regenerated when their definition (in montage.yml) has
  changed, or if the contents of the source files have changed.

* The `montage init` command now uses the highline gem to ask for the paths to
  a project's source files, and the intended sprite output directory.

* Running `montage init` will copy some sample source files into the source
  directory. This allows running `montage` immediately after creating the
  project, to see how things work.

v0.1.1 - 2010-04-05
-------------------

* Small fix for Ruby 1.9.1, which doesn't define String#inject.

v0.1.0 - 2010-04-05
-------------------

* Initial release. Supports creation of sprites and not much else.
