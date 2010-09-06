@flexo-generate
Feature: The sprite cache

  Since optimising sprites can take a while
  I want to create new sprite files only when a source has changed

  Scenario: Generating two sprites, one of which is unchanged
    Given I have a default project
      And I have 2 sources in public/images/sprites/fry
      And I have 1 source in public/images/sprites/leela
    When I run "flexo"
      And I have a "one" source at public/images/sprites/fry which is 100x25
    When I run "flexo"
    Then the exit status should be 0
      And the "fry" sprite should have been re-generated
      And the "leela" sprite should not have been re-generated
      And the "fry" sprite should have been optimised
      And the "leela" sprite should not have been optimised
      And the "fry" sprite should be 100x65
      And the "leela" sprite should be 50x20

  Scenario: Generating two sprites, one of which is unchanged, with --force
    Given I have a default project
      And I have 2 sources in public/images/sprites/fry
      And I have 1 source in public/images/sprites/leela
    When I run "flexo"
      And I have a "one" source at public/images/sprites/fry which is 100x25
    When I run "flexo --force"
    Then the exit status should be 0
      And the "fry" sprite should have been re-generated
      And the "leela" sprite should have been re-generated
      And the "fry" sprite should have been optimised
      And the "leela" sprite should have been optimised

  Scenario: Generating an unchanged sprite which has been deleted
    Given I have a default project
      And I have 1 source in public/images/sprites/fry
    When I run "flexo"
      And I delete the file public/images/fry.png
    When I run "flexo"
    Then the exit status should be 0
      And the "fry" sprite should have been re-generated
      And the "fry" sprite should have been optimised
