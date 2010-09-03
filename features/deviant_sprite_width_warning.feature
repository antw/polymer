Feature: Warning about sprites with wildly varying widths

  Since sprites are as wide as their widest source
  And wide images will result in larger file-sizes
  Warn when one or more source images are much wider than the average

  Scenario: Generating a sprite with a very wide source
    Given I have a default project
      And I have 4 sources in public/images/sprites/fry
      And I have a "five" source at public/images/sprites/fry which is 500x1
    When I run "flexo"
    Then the output should contain:
      """
      The "five" source image in the "fry" sprite deviates significantly from the average width
      """
