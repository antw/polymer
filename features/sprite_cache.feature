@polymer-bond
Feature: The sprite cache

  Since optimising sprites can take a while
  I want to create new sprite files only when a source has changed

  Scenario: Generating two sprites, one of which is unchanged
    Given I have a default project
      And I have 2 sources in sources/fry
      And I have 1 source in sources/leela
    When I run "polymer bond"
      And I have a "one" source at sources/fry which is 100x25
    When I run "polymer bond"
    Then the exit status should be 0
      And the "fry" sprite should have been re-generated
      And the "leela" sprite should not have been re-generated
      And the "fry" sprite should be 100x65
      And the "leela" sprite should be 50x20

  Scenario: Generating two sprites, one of which is unchanged, with --force
    Given I have a default project
      And I have 2 sources in sources/fry
      And I have 1 source in sources/leela
    When I run "polymer bond"
      And I have a "one" source at sources/fry which is 100x25
    When I run "polymer bond --force"
    Then the exit status should be 0
      And the "fry" sprite should have been re-generated
      And the "leela" sprite should have been re-generated

  Scenario: Generating an unchanged sprite which has been deleted
    Given I have a default project
      And I have 1 source in sources/fry
    When I run "polymer bond"
      And I delete the file sprites/fry.png
    When I run "polymer bond"
    Then the exit status should be 0
      And the "fry" sprite should have been re-generated

  Scenario: Generating an unchanged sprite when the cache is disabled
    Given I have a project with config:
      """
      config.cache false

      sprites 'sources/:name/*' => 'sprites/:name.png'
      """
      And I have 1 source in sources/fry
    When I run "polymer bond"
    When I run "polymer bond"
    Then the exit status should be 0
      And the "fry" sprite should have been re-generated
