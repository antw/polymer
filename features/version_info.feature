Feature: Showing the Flexo version

  In order that I can find out how recent my copy of Flexo is
  I want to be able to print the version

  Scenario: Showing the version
    When I run "flexo --version"
    Then the stdout should contain the Flexo version
