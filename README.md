Polymer
=======

This file is an example of [Readme Driven Development][rdd], and not
everything will work as written... _yet_. Polymer's prececessor --
[Montage][montage] -- should provide for most of your needs until Polymer
is released.

Synopsis
--------

Popularised by Dave Shea in an [A List Apart][ala], "sprite" images
combine many smaller images into a single larger image, with CSS then
being used to divide the sprite back into it's constituent parts.

However, creating sprites burdens the developer with the need to
manually update them every time a minor change is required. Even more
frustrating is the need to remember the precise background positions
required when editing the CSS.

Polymer is a library which, provided a simple configuration file, will
automate this process, optimise the sprites, and if you're a SASS
user, you're in for a treat: Polymer generates mixins which make working
with your sprites incredibly simple:

    SASS Usage:

      #navigation
        a#home, a#products
          +polymer("main/home")
        a#products
          +polymer-pos("main/products")

    Generated CSS:

      #navigation a#home, #navigation a#products {
        background: url(/path/to/sprite.ext) 0 0 no-repeat; }

      #navigation a#products {
        background-position: 0 -40px; }

Polymer was split out from [Kin][kin] in 2009 after it became clear that
Merb was dead (R.I.P.), and a flexible image spriter was sorely needed
on other projects.

Polymer follows the rules of [Semantic Versioning][semver] and uses
[YARD][yard] for API documentation.

Installation
------------

The recommended way to install Polymer is with Rubygems:

    $ [sudo] gem install polymer

"Out of the box" Polymer will use the ChunkyPNG library to read and write
images. This allows Polymer to run on both JRuby and Rubinius. In order
to read foramts other than PNG requires that you have RMagick (and
ImageMagick) installed on your system. However, you do not need to
install RMagick immediately, however; Polymer will tell you to do so if
you ask it to work on an image not supported by ChunkPNG.

If you wish to install Polymer from source:

    $ git clone http://github.com/antw/polymer.git && cd polymer
    $ gem build polymer.gemspec
    $ [sudo] gem install --local polymer-VERSION.gem

(Where "VERSION" is the current version of Polymer).

Features
--------

Coming soon.

Usage
-----

Coming soon.

Ward specs are run against:

* Ruby (MRI) 1.8.7 p302,
* Ruby (YARV) 1.9.1 p378,
* Ruby (YARV) 1.9.2 p0.

Polymer requires RMagick which presently rules out support for JRuby and
Rubinius.

Contributing
------------

A Bundler Gemfile is provided to simplify installing Polymer's
dependencies. Running `bundle install` will install everything needed to
contribute. Bundler is not used in the Polymer library itself.

* Fork the project, taking care not to get any in your eyes.

* Make your feature addition or bug fix.

* Add tests for it. This is especially important not only because it
  helps ensure that I don't unintentionally break it in a future
  version, but also since it appeases Epidity, God of Potatoes, who has
  been known to shower rancid cucumbers upon those who fail to test.

* Commit, but please do not mess with the Rakefile or history. If you
  want to have your own version, _that is fine_, but bump the version in
  a commit by itself so that I can ignore it when I pull.

* Send me a pull request. Bonus points for topic branches (although
  "everything is made up, and the points don't matter...").

Details
-------

**Source**
:  [http://github.com/antw/polymer][polymer]

**Author**
:  Anthony Williams

**Copyright**
:  2009-2010

**License**
:  BSD License

Polymer &copy; 2009-2010 by [Anthony Williams](mailto:hi@antw.me).
Polymer is free software, released under the BSD license. Please see the
LICENSE file for more information.

The sample sources in lib/polymer/templates/sources are courtesy of
[Yusuke Kamiyamane][yusuke], whose extraordinary
generosity in releasing three-thousand royalty-free icons cannot be
stated enough.

[rdd]:       http://tom.preston-werner.com/2010/08/23/readme-driven-development.html
[montage]:   http://github.com/antw/montage
[polymer]:   http://github.com/antw/polymer
[ala]:       http://www.alistapart.com/articles/sprites
[kin]:       http://github.com/antw/kin
[semver]:    http://semver.org/
[yard]:      http://yardoc.org/
[yusuke]:    http://p.yusukekamiyamane.com
