@polymer-optimise
Feature: The optimisation cache

  Since optimising images can take a while
  I want to run optimisers only on images which haven't already been optimised

  Scenario: Optimising two images, one of which is unoptimised
    Given I have a default project
      And I have a one.png image
      And I have a two.png image
      And I run "polymer optimise one.png"
    When I run "polymer optimise one.png two.png"
    Then the exit status should be 0
      And "two.png" should have been optimised
      And "one.png" should not have been optimised

  Scenario: Forcing optimisation
    Given I have a default project
      And I have a one.png image
      And I run "polymer optimise one.png"
    When I run "polymer optimise one.png --force"
    Then the exit status should be 0
      And "one.png" should have been optimised

  Scenario: Directory agnosticism
    Given I have a default project
      And I have a one.png image
      And I run "polymer optimise one.png"
    When I run "polymer optimise ../one.png" in sprites/
    Then the exit status should be 0
      And "one.png" should not have been optimised
