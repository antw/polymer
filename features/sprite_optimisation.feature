@flexo-generate @flexo-optimise @pending
Feature: Optimising sprites after generation

  In order to reduce the payload sent to users of application
  I want to be able to reduce images to their smallest possible size

  Scenario: Optimising when generating new sprites
    Given I have a default project
      And I have 1 source in public/images/sprites/fry
    When I run "flexo generate"
    Then the exit status should be 0
      And the "fry" sprite should have been optimised

  Scenario: Optimising only changed sprites
    Given I have a default project
      And I have 1 source in public/images/sprites/fry
      And I have 1 source in public/images/sprites/leela
      And I run "flexo generate"
      And I have a "one" source at public/images/sprites/fry which is 100x25
    When I run "flexo generate"
    Then the exit status should be 0
      And the "fry" sprite should have been optimised
      And the "leela" sprite should not have been optimised

  Scenario: Optimising generated sprites with --force
    Given I have a default project
      And I have 1 source in public/images/sprites/fry
      And I run "flexo generate"
    When I run "flexo generate --force"
    Then the "fry" sprite should have been optimised