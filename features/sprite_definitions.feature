Feature: Sprite definitions

  Scenario: A config file with one sprite containing three sources
    Given a config file like
      """
      ---
        sprite_one:
          - one
          - two
          - three

      """
    Then the project should have 1 sprite defined
      And sprite "sprite_one" should have 3 sources

  Scenario: A config file with two sprites
    Given a config file like
      """
      ---
        sprite_one:
          - one
          - two
          - three

        sprite_two:
          - four
          - five

      """
    Then the project should have 2 sprites defined
      And sprite "sprite_one" should have 3 sources
      And sprite "sprite_two" should have 2 sources
