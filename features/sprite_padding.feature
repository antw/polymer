@flexo-generate
Feature: Setting the transparent padding between source images

  In order to make sprites more useable where the size of an element is large
  I want to be able to change the padding between the source images

  Scenario: Creating a single sprite with global custom padding
    Given I have a project with config:
      """
      ---
        config.padding: 50

        "public/images/sprites/:name/*.png":
          to: "public/images/:name.png"
      """
      And I have 2 sources in public/images/sprites/fry
    When I run "flexo generate"
    Then the exit status should be 0
      And the "fry" sprite should have been generated
      And the "fry" sprite should be 50x90

  Scenario: Creating a single sprite with custom sprite padding
    Given I have a project with config:
      """
      ---
        "public/images/sprites/fry/*.png":
          to: "public/images/fry.png"
          padding: 50

        "public/images/sprites/leela/*.png":
          to: "public/images/leela.png"
      """
      And I have 2 sources in public/images/sprites/fry
      And I have 2 sources in public/images/sprites/leela
    When I run "flexo generate"
    Then the exit status should be 0
      And the "fry" sprite should have been generated
      And the "leela" sprite should have been generated
      And the "fry" sprite should be 50x90
      And the "leela" sprite should be 50x60

  Scenario: Creating a single sprite with zero padding
    Given I have a project with config:
      """
      ---
        config.padding: 0

        "public/images/sprites/:name/*.png":
          to: "public/images/:name.png"
      """
      And I have 2 sources in public/images/sprites/fry
    When I run "flexo generate"
    Then the exit status should be 0
      And the "fry" sprite should have been generated
      And the "fry" sprite should be 50x40
