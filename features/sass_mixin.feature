@flexo-generate
Feature: Sass mixin files

  In order to make Flexo awesome
  It should generate Sass mixins

  Scenario: Creating a Sass mixin with a sprite
    Given I have a default project
      And I have 1 source in public/images/sprites/fry
    When I run "flexo"
    Then the exit status should be 0
      And a Sass mixin should exist

  Scenario: Disabling Sass in the config file
    Given I have a project with config:
    """
    ---
      config.sass: false

      "public/images/sprites/:name/*.{png,jpg,jpeg,gif}":
        to: "public/images/:name.png"
    """
    Then a Sass mixin should not exist
