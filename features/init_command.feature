@polymer-init
Feature: The init command

  In order to simplify creation of new Polymer projects
  I want a simple command which does it for me

  Scenario: Initializing with default settings
    When I run "polymer init"
    Then the exit status should be 0
      And .polymer should be a file
      And .polymer should expect default sources in public/images/sprites
      And .polymer should expect default sprites to be saved in public/images
      And the fixture sources should exist in public/images/sprites

  Scenario: Initializing in an existing project
    When I run "polymer init"
    When I run "polymer init"
    Then the exit status should be 1
      And the stdout should contain "A .polymer file already exists"

  Scenario: Initializing with a custom sprite directory
    When I run "polymer init --sprites public/other"
    Then the exit status should be 0
      And .polymer should expect default sources in public/other/sprites
      And .polymer should expect default sprites to be saved in public/other
      And the fixture sources should exist in public/other/sprites

  Scenario: Initializing with a custom sprite and source directory
    When I run "polymer init --sprites public/other --sources src/sprites"
    Then the exit status should be 0
      And .polymer should expect default sources in src/sprites
      And .polymer should expect default sprites to be saved in public/other
      And the fixture sources should exist in src/sprites

  Scenario: Initializing without example images
    When I run "polymer init --no-examples"
    Then the exit status should be 0
      And .polymer should be a file
      And the fixture sources should not exist

  Scenario: Initializing with a Windows config file
    When I run "polymer init --windows"
    Then the exit status should be 0
      And polymer.rb should be a file
      And polymer.rb should expect the cache to be at polymer.cache
    When I run "polymer bond --fast"
    Then the exit status should be 0
