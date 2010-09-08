@flexo-generate
Feature: Generating sprites with Flexo

  In order to create sprites
  I want to be able to run a simple command to do this

  Scenario: Creating a sprite with two sources
    Given I have a default project
      And I have 2 sources in public/images/sprites/fry
    When I run "flexo generate"
    Then the exit status should be 0
      And the "fry" sprite should have been generated
      And the "fry" sprite should be 50x60

  Scenario: Creating two sprites at once
    Given I have a default project
      And I have 1 source in public/images/sprites/fry
      And I have 1 source in public/images/sprites/leela
    When I run "flexo generate"
    Then the exit status should be 0
      And the "fry" sprite should have been generated
      And the "leela" sprite should have been generated

  Scenario: When specifying specific sprites to generate
    Given I have a default project
      And I have 1 source in public/images/sprite/fry
      And I have 1 source in public/images/sprite/leela
    When I run "flexo generate fry"
    Then the exit status should be 0
      And the "fry" sprite should have been generated
      And the "leela" sprite should not have been generated

  Scenario: Generating sprites in a non-project directory
    When I run "flexo generate"
    Then the exit status should be 1
      And the stdout should contain "Couldn't find a Flexo project"

  Scenario: Generating sprites when the sprite directory is not writable
    Given I have a default project
      And I have 1 source in public/images/sprites/fry
      And public/images is not writable
    When I run "flexo generate"
    Then the exit status should be 1
      And the stdout should contain "can't save the fry sprite"
      And the stdout should contain "isn't writable"
