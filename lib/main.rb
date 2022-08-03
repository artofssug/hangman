require 'json'

module GameTxt
  def welcome_txt
    puts 'Welcome to my implementation of Hangman!'
  end

  def user_answer
    @answer = gets.chomp.strip.downcase
    until %w[yes no].any?(@answer)
      print "\'#{@answer}\' is not a valid answer. Please, enter 'yes' or 'no': "
      @answer = gets.chomp.strip.downcase
    end
  end

  def show_rules?
    print "\nDo you want to see a quick tutorial? Enter 'yes' or 'no': "
    user_answer
    rules if @answer == 'yes'
  end

  private

  def rules
    puts "\nThe game is pretty simple:"
    puts 'My script will randomly select a word between 5 and 12 characters long,'
    puts 'and all you need to do is to guess, letter by letter, the secret word!'
    puts 'And you have 20 turns to guess or you lose!'
    puts 'Pretty simple, right?'
    puts "\nSo... shall we begin?"
  end
end

class Hangman
  include GameTxt
  def initialize
    @dictionary = File.read('./google-10000-english-no-swears.txt').split
    generate_secret_word
    @hidden_word = @secret_word.split('').map { '_' }
    @valid_letters = []
    @user_guesses = []
    @turn = 1
  end

  private

  def generate_secret_word
    @secret_word = @dictionary.sample
    @secret_word = @dictionary.sample until @secret_word.length.between?(5, 12)
  end

  public

  def game
    while @turn <= 20 do
      puts "\nTurn #{@turn}/20!"
      puts "\nSecret code: #{@hidden_word.join(' ')} (#{@hidden_word.length} characters long)"
      unless @turn == 1
        puts "\nThis is the letters you already entered: #{@user_guesses}"
        print "\nDo you want to save the game? Enter 'yes' or 'no': "
        user_answer
        serialize_game if @answer == 'yes'
      end
      guess
      puts "\nUnfortunately, this was the last round and you didn't discovered the secret word. You lose!" if @turn == 20
      break if winner?
      @turn += 1
    end
  end

  private

  def serialize_game
    File.open('save_game.json', 'w') do |file|
      file.write(JSON.dump({
                             secret_word: @secret_word,
                             hidden_word: @hidden_word,
                             valid_letters: @valid_letters,
                             user_guesses: @user_guesses,
                             turn: @turn
                           }))
    end
    puts "\nGame Saved!"
  end

  public

  def deserialize_game
    save = File.read('save_game.json')
    data = JSON.parse(save)
    @secret_word = data['secret_word']
    @hidden_word = data['hidden_word']
    @valid_letters = data['valid_letters']
    @user_guesses = data['user_guesses']
    @turn = data['turn']
    File.delete('save_game.json')
  end

  private

  def guess
    print "\nEnter a letter: "
    user_guess
    check_guess
  end

  def user_guess
    @guess = gets.chomp.strip.downcase

    while @guess.length > 1 || @valid_letters.include?(@guess) || @guess == '' || @guess.nil?
      if @valid_letters.include?(@guess)
        print "Seems you already entered '#{@guess}'. Enter another letter: "
      else
        print "\'#{@guess}\' is not a valid option. Enter another letter: "
      end
      @guess = gets.chomp.strip.downcase
    end
  end

  def check_guess
    @user_guesses << @guess
    return unless @secret_word.include?(@guess)

    @valid_letters << @guess
    @hidden_word = @secret_word.split('').map do |chr|
      if @valid_letters.any?(chr)
        @valid_letters.select { |letter| letter == chr }
      else
        '_'
      end
    end
  end

  def winner?
    return unless @hidden_word.join == @secret_word

    puts "\nThis is the letters you already entered: #{@user_guesses}"
    puts "\nSecret code: #{@hidden_word.join(' ')} (#{@hidden_word.length} characters long)"
    puts "\nCongratulations! You discovered the secret word!"
    true
  end
end

hangman = Hangman.new
hangman.welcome_txt

if File.exist?('save_game.json')
  print "\nDo you want to load your previous save? Enter 'yes' or 'no': "
  answer = gets.chomp.strip.downcase
  until %(yes no).include?(answer)
    print "\'#{answer}\' is not a valid answer. Please, enter 'yes' or 'no': "
    answer = gets.chomp.strip.downcase
  end

  case answer
  when 'yes' then hangman.deserialize_game
  else hangman.show_rules?
  end
else
  hangman.show_rules?
end
hangman.game
