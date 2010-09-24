@polymer-bond
Feature: Generating sprites with Polymer

  In order to create sprites
  I want to be able to run a simple command to do this

  Scenario: Creating a sprite with two sources
    Given I have a default project
      And I have 2 sources in sources/fry
    When I run "polymer bond"
    Then the exit status should be 0
      And the "fry" sprite should have been generated
      And the "fry" sprite should be 50x60

  Scenario: Creating two sprites at once
    Given I have a default project
      And I have 1 source in sources/fry
      And I have 1 source in sources/leela
    When I run "polymer bond"
    Then the exit status should be 0
      And the "fry" sprite should have been generated
      And the "leela" sprite should have been generated

  Scenario: When specifying specific sprites to generate
    Given I have a default project
      And I have 1 source in sources/fry
      And I have 1 source in sources/leela
    When I run "polymer bond fry"
    Then the exit status should be 0
      And the "fry" sprite should have been generated
      And the "leela" sprite should not have been generated

  Scenario: Generating sprites in a non-project directory
    When I run "polymer bond"
    Then the exit status should be 1
      And the stdout should contain "Couldn't find a Polymer project"

  Scenario: Generating sprites when the sprite directory is not writable
    Given I have a default project
      And I have 1 source in sources/fry
      And sprites is not writable
    When I run "polymer bond"
    Then the exit status should be 1
      And the stdout should contain "can't save the fry sprite"
      And the stdout should contain "isn't writable"
