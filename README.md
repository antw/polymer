Flexo
=====

**Source**
:  [http://github.com/antw/flexo](http://github.com/antw/flexo)

**Author**
:  Anthony Williams

**Copyright**
:  2009-2010

**License**
:  BSD License

SYNOPSIS
--------

Popularised by Dave Shea in an
[A List Apart](http://www.alistapart.com/articles/sprites), "sprite"
images combine many smaller images into a single larger image, with CSS
then being used to divide the sprite back into it's constituent parts.

However, creating sprites burdens the developer with the need to
manually update them every time a minor change is required. Even more
frustrating is the need to remember the precise background positions
required when editing the CSS.

Flexo is a library which, provided a simple configuration file, will
automate this process, optimise the sprites, and if you're a SASS
user, you're in for a treat: Flexo generates mixins which make working
with your sprites incredibly simple:

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

Flexo was been split out from [Kin](http://github.com/antw/kin) in 2009
after it became clear that Merb was dead (R.I.P.), and a flexible image
spriter was sorely needed on other projects. Flexo is named after
Bender's "good" twin in Futurama.

INSTALLATION
------------

To install with RubyGems, simply `gem install flexo`; Flexo, and it's
dependencies, will be installed for you.

If you wish to install from source:

    gem build flexo.gemspec
    gem install --local flexo-VERSION.gem

(Where "VERSION" is the current version of Flexo).

FEATURE LIST
------------

Coming soon.

USAGE
-----

Coming soon.

Ward specs are run against:

* Ruby (MRI) 1.8.7 p302,
* Ruby (YARV) 1.9.1 p378,
* Ruby (YARV) 1.9.2 p0.

Flexo requires RMagick which presently rules out support for JRuby and
Rubinius.

CONTRIBUTING
------------

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

COPYRIGHT
---------

Flexo &copy; 2009-2010 by [Anthony Williams](mailto:hi@antw.me).
Licensed under the BSD license. Please see the {file:LICENSE} for more
information.

The sample sources in lib/flexo/templates/sources are courtesy of
[Yusuke Kamiyamane](http://p.yusukekamiyamane.com), whose extraordinary
generocity in releasing three-thousand royalty-free icons cannot be
stated enough.
