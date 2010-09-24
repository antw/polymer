@polymer-version
Feature: Showing the Polymer version

  In order that I can find out how recent my copy of Polymer is
  I want to be able to print the version

  Scenario: Showing the version
    When I run "polymer --version"
    Then the stdout should contain the Polymer version
