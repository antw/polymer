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
      And the stdout should contain "optimised  two.png"
      And the stdout should not contain "optimised  one.png"

  Scenario: Forcing optimisation
    Given I have a default project
      And I have a one.png image
      And I run "polymer optimise one.png"
    When I run "polymer optimise one.png --force"
    Then the exit status should be 0
      And the stdout should contain "optimised  one.png"

  Scenario: Directory agnosticism
    Given I have a default project
      And I have a one.png image
      And I run "polymer optimise one.png"
      And I change directory to sprites/
    When I run "polymer optimise one.png"
    Then the exit status should be 0
      And the stdout should not contain "optimised  one.png"
