Montage
=======

_"[Even Rocky had a montage](http://www.youtube.com/watch?v=yLuOl36vamI)."_

**Source**
:  [http://github.com/antw/montage](http://github.com/antw/montage)

**Author**
:  Anthony Williams

**Copyright**
:  2009-2010

**License**
:  MIT License

SYNOPSIS
--------

Popularised by Dave Shea in an
[A List Apart](http://www.alistapart.com/articles/sprites), "sprite"
images combine many smaller images into a single, larger image, with CSS
then being used to divide the sprite back into it's constituent parts.

However, creating sprites burdens you with having to manually update
them every time a minor change is required. Even more frustrating is the
need to remember the precise background positions required when editing
the CSS.

Montage is a library which, provided a simple configuration file, will
automate this process, and if you're a SASS user, you're in for a treat:
Montage generates mixins which make working with your sprites incredibly
simple:

    SASS Usage:

      #navigation
        a#home, a#products
          +main-sprite("home")
        a#products
          +main-sprite-pos("products")

    Generated CSS:

      #navigation a#home, #navigation a#products {
        background: url(/path/to/sprite.ext) 0 0 no-repeat; }

      #navigation a#products {
        background-position: 0 -40px; }

Montage has been split out from [Kin](http://github.com/antw/kin) -- a
collection of various bits-and-bobs from my Merb projects.

Montage is pretty primitive in that it stacks each image in a single
column. This is perfect when your source images are of a similar width
(such as is the case with icons), but not so good when they vary
significantly in size.

INSTALLING
----------

To install with RubyGems, simply `gem install montage`; Montage, and
it's dependencies, will be installed for you.

If you wish to install from source:

    gem build montage.gemspec
    gem install --local montage-VERSION.gem

(Where "VERSION" is the current version of Montage).

FEATURE LIST
------------

Coming soon.

USAGE
-----

Coming soon.

Ward specs are run against:

* Ruby (MRI) 1.8.6 p399,
* Ruby (MRI) 1.8.7 p249,
* Ruby (YARV) 1.9.1 p378,

Montage requires RMagick which presently rules out support for JRuby and
Rubinius.

CONTRIBUTING
------------

* Fork the project, taking care not to get any in your eyes.

* Make your feature addition or bug fix.

* Add tests for it. This is especially important not only because it
  helps ensure that I don't unintentionally break it in a future
  version, but also since it appeases Phyllis --- the goddess of
  Cucumbers --- who has been known to rain showers of fresh vegetables
  on those who don't write tests.

* Commit, but do not mess with the Rakefile, VERSION, or history. If you
  want to have your own version, that is fine, but bump version in a
  commit by itself so that I can ignore it when I pull.

* Send me a pull request. Bonus points for topic branches. But we all
  know everything is made up and the points don't matter.

COPYRIGHT
---------

Montage &copy; 2009-2010 by [Anthony Williams](mailto:hi@antw.me).
Licensed under the MIT license. Please see the {file:LICENSE} for more
information.

The sample sources in lib/montage/templates/sources are courtesy of
Yusuke Kamiyamane: http://p.yusukekamiyamane.com

