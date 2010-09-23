@flexo-generate
Feature: Warning about sprites with wildly varying widths

  Since sprites are as wide as their widest source
  And wide images will result in larger file-sizes
  Warn when one or more source images are much wider than the average

  Scenario: Generating a sprite with a very wide source
    Given I have a default project
      And I have 4 sources in sources/fry
      And I have a "five" source at sources/fry which is 300x1
      And I have a "six" source at sources/fry which is 300x1
    When I run "flexo generate"
    Then the output should contain:
      """
      Your "fry" sprite contains one or more source images which deviate significantly
      """
    And the output should contain:
      """
      Wide sources: five, six
      """
