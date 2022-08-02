class Hangman

  def initialize
    @dictionary = File.read('google-10000-english-no-swears.txt').split
    @secret_word = generate_word
  end

  def generate_word
    @secret_word = @dictionary.sample
    @secret_word = @dictionary.sample until @secret_word.length.between?(5, 12)
    p @secret_word
  end

end

Hangman.new