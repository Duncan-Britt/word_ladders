(This may be of use: https://github.com/filiph/english_words/blob/master/data/word-freq-top5000.csv)

- Store same-length word lists in PostgreSQL database
  - Get all words in the English dictionary as list
  - Divide list into lists of words for every word length
    - Length Lists: [
      empty slot,
      empty slot,
      [ to, it, be, is, as, on, no, me . . .],
      [ the, for, put, bet, set, get, pet, nor. . .],
      [ four . . . ],
      etc . . .
    ]
  - create tables for every word length
- Be able to automatically generate word ladders of varying difficult
  - difficulty setting determines max ladder length and word length
    - WordLadder.new(difficulty_setting) creates a word ladder of
      appropriate difficulty
<!-- - For every fixed length word list, generate every possible word ladder
  - is this feasible?
    - would it take too much time to execute?
    - test by prototyping the generator of every possible word ladder for two-letter words
      - start with several words before doing all
- In the event that you can't generate EVERY possible word ladder
  - (which seems likely)
  - Generate word ladders on the fly from list of words
    - do so randomly, by brute force:
      - start with a random word from list
      - iterate through list until an adjacent word is found
        - word is adjacent if all but one letter are equal
      - keeping adding adjacent words until word ladder is of sufficient length
        - make sure there are no duplicate words
      - CONCERNS:
        - what if the final word is closer or as close to the original word as the
          intermediary words, or otherwise, what if steps are redundant?
          - EXAMPLES:
            - fun => run => gun
            - fun => fan => ran => run
          - SOLUTION:
            - For every index of word, store a list of previously used letters
            - don't allow letters to repeat
            - CRITICISM:
              - This would prevent: fun => gun => gum => gym => wyn
              - It's a bad solution. Probably should use a smarter method of
                generating word ladders -->

- use just 5k word set. More words = lower quality words
- No need to store graph of words in a graph database. File storage is plenty fast
  for 5k words. Although, you could, and that might be interesting
- can store a longer list of words in PostgreSQL just to validate user input
  words which may not be in the 5k word set.

Store data on amazon s3 as files
https://devcenter.heroku.com/articles/active-storage-on-heroku
  - this solution only works for smaller numbers of words, like the most
    common 5000 english words. It can't work for 135K, so a database would
    have to be used for that.

Consider Orientdb
http://orientdb.com/docs/3.0.x/gettingstarted/
https://orientdb.org/cloud/orientdb-amazon-web-services
