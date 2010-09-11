@flexo-position
Feature: Source position command

  In order to permit users to create their own stylsheets
  I want to be able to find the position of a source image

  Scenario: Specifying a source name
    Given I have a default project
      And I have 2 sources in public/images/sprites/fry
      And I have 2 sources in public/images/sprites/leela
    When I run "flexo position two"
    Then the exit status should be 0
      And the output should contain:
      """
      fry/two: 40px
          background: url(/images/fry.png) 0 -40px no-repeat;
        - or -
          background-position: 0 -40px;
      """
      And the output should contain:
      """
      leela/two: 40px
          background: url(/images/leela.png) 0 -40px no-repeat;
        - or -
          background-position: 0 -40px;
      """

  Scenario: Specifying a sprite/source pair
    Given I have a default project
      And I have 2 sources in public/images/sprites/fry
      And I have 2 sources in public/images/sprites/leela
    When I run "flexo position fry/two"
    Then the exit status should be 0
      And the output should contain:
      """
      fry/two: 40px
          background: url(/images/fry.png) 0 -40px no-repeat;
        - or -
          background-position: 0 -40px;
      """

  Scenario: Specifying a source which does not exist
    Given I have a default project
      And I have 1 source in public/images/sprites/fry
    When I run "flexo position invalid"
    Then the exit status should be 1
      And the output should contain "No such source: invalid"

  Scenario: Specifying a sprite/source which does not exist
    Given I have a default project
      And I have 1 source in public/images/sprites/fry
    When I run "flexo position fry/invalid"
    Then the exit status should be 1
      And the output should contain "No such source: invalid"

  Scenario: Specifying a sprite which does not exist
    Given I have a default project
    When I run "flexo position fry/invalid"
    Then the exit status should be 1
      And the output should contain "No such sprite: fry"
