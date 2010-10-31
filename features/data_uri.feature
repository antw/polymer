@polymer-bond
Feature: Using Data URIs instead of a file

  In order to further decrease the number of requests
  It should be possible to "in-line" sprites as a CSS data URI

  Scenario: Creating a Sass file with a data URI
    Given I have a project with config:
      """
      sprite 'sources/fry/*'    => :data_uri, :name => 'fry'
      sprite 'sources/leela/*'  => :data_uri, :name => 'leela'
      sprite 'sources/bender/*' => 'sprites/bender.png'
      """
      And I have 1 source in sources/fry
      And I have 1 source in sources/leela
      And I have 1 source in sources/bender
    When I run "polymer bond"
    Then the Sass file should contain a data URI for "fry"
      And the Sass file should contain a data URI for "leela"
      And the Sass file should not contain a data URI for "bender"

  Scenario: Creating a Sass file with a data URI and a source glob
    Given I have a project with config:
      """
      sprites 'sources/:name/*' => :data_uri
      """
      And I have 1 source in sources/fry
      And I have 1 source in sources/leela
    When I run "polymer bond"
    Then the Sass file should contain a data URI for "fry"
      And the Sass file should contain a data URI for "leela"
