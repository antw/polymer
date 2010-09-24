@polymer-generate
Feature: Sass mixin files

  In order to make Polymer awesome
  It should generate Sass mixins

  Scenario: Creating a Sass mixin with a sprite
    Given I have a default project
      And I have 1 source in sources/fry
    When I run "polymer generate"
    Then the exit status should be 0
      And a Sass mixin should exist
      And the stdout should contain "written  Sass"

  Scenario: When nothing is generated
    Given I have a default project
      And I have 1 source in sources/fry
      And I run "polymer generate"
    When I run "polymer generate"
    Then the stdout should not contain "written  Sass"

  Scenario: Disabling Sass in the config file
    Given I have a project with config:
    """
    ---
      config.sass false

      sprites 'sources/:name/*' => 'sprites/:name.png'
    """
    Then a Sass mixin should not exist
