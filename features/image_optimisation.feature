@polymer-optimise
Feature: Optimisation of non-sprite images

  In order optimise other PNG images I have in my project
  I want to be able to use Polymer's optimisation on them

  Scenario: Optimising an image
    Given I have a default project
      And I have a one.png image
    When I run "polymer optimise one.png"
    Then the exit status should be 0
      And the stdout should contain "optimised  one.png"

  Scenario: en-us support
    Given I have a default project
      And I have a one.png image
    When I run "polymer optimize one.png"
    Then the exit status should be 0
      And the stdout should contain "optimised  one.png"

  Scenario: Skipping non-PNGs
    Given I have a default project
      And I have a one.jpg image
    When I run "polymer optimise one.jpg"
    Then the exit status should be 0
      And the stdout should contain "skipped  one.jpg"

  Scenario: Optimising multiple images
    Given I have a default project
      And I have a one.png image
      And I have a two.png image
    When I run "polymer optimise one.png two.png"
    Then the exit status should be 0
      And the stdout should contain "optimised  one.png"
      And the stdout should contain "optimised  two.png"

  Scenario: Optimising images with a glob
    Given I have a default project
      And I have a one.png image
      And I have a two.png image
    When I run "polymer optimise *.png"
    Then the exit status should be 0
      And the stdout should contain "optimised  one.png"
      And the stdout should contain "optimised  two.png"

  Scenario: Optimising images with a directory
      Given I have a default project
      And I have a images/one.png image
      And I have a images/two.png image
      And I have a images/other/three.png image
    When I run "polymer optimise images"
    Then the exit status should be 0
      And the stdout should contain "optimised  images/one.png"
      And the stdout should contain "optimised  images/two.png"
      And the stdout should contain "optimised  images/other/three.png"

  Scenario: Optimising an image without a project
    Given I have a one.png image
    When I run "polymer optimise one.png"
    Then the exit status should be 0
      And the stdout should contain "optimised  one.png"
