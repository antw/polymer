@flexo-init
Feature: The init command

  In order to simplify creation of new Flexo projects
  I want a simple command which does it for me

  Scenario: Initializing with default settings
    When I run "flexo init"
    Then the exit status should be 0
      And .flexo should be a file
      And .flexo should expect default sources in public/images/sprites
      And .flexo should expect default sprites to be saved in public/images
      And the fixture sources should exist in public/images/sprites

  Scenario: Initializing in an existing project
    When I run "flexo init"
    When I run "flexo init"
    Then the exit status should be 1
      And the stdout should contain "A .flexo file already exists"

  Scenario: Initializing with a custom sprite directory
    When I run "flexo init --sprites public/other"
    Then the exit status should be 0
      And .flexo should expect default sources in public/other/sprites
      And .flexo should expect default sprites to be saved in public/other
      And the fixture sources should exist in public/other/sprites

  Scenario: Initializing with a custom sprite and source directory
    When I run "flexo init --sprites public/other --sources src/sprites"
    Then the exit status should be 0
      And .flexo should expect default sources in src/sprites
      And .flexo should expect default sprites to be saved in public/other
      And the fixture sources should exist in src/sprites

  Scenario: Initializing without example images
    When I run "flexo init --no-examples"
    Then the exit status should be 0
      And .flexo should be a file
      And the fixture sources should not exist
