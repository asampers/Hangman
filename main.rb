require 'yaml'

module Display

  def populate_dictionary
    dictionary = []
    File.open("words.txt").readlines.each do |line|
      dictionary << line.chomp unless line.length < 6 || line.length > 13
    end
    dictionary.sample
  end

end

module GameLogic
  def update_word_progress(secret_word, current_guess, word_progress)
    secret_word.each_with_index do |ltr, i|
      if ltr == current_guess
        word_progress[i] = "#{current_guess} "
      end
    end 
    puts "Game progress: #{word_progress.join}"
    return current_guess   
  end

  def update_ltrs_guessed(secret_word, current_guess, ltrs_guessed)
    if !(secret_word.include?(current_guess))
      ltrs_guessed << current_guess
      puts"Incorrect letters: #{ltrs_guessed.join.to_s.upcase}"
      return true
    end
    puts"Incorrect letters: #{ltrs_guessed.join.to_s.upcase}"
  end

  def won?(secret_word, word_progress, player)
    if secret_word.join == word_progress.join.delete(" ")
      puts "Secret word: #{secret_word.join}"
      puts "Congratulations, #{player}! You guessed correctly!"
      return true
    end 
  end  

  def lost(secret_word, player)
    puts "Sorry, #{player}. You ran out of guesses. The word was '#{secret_word.join}'."   
  end
end

module SavedGames

  def play_from_saved_game
    if Dir.glob('saved_games/*').length > 0
      puts "Would you like to play from a saved game? Y or N"
      answer = gets.chomp.upcase
      if answer == "Y"
        choose_saved_game()
      end
    end
  end  

  def save_game(game)
    puts "...saving game..."
    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
    puts "What would you like to name your saved game?"
    answer = gets.chomp 
    filename = "saved_games/#{answer}.yml"

    File.open(filename, 'w') {|file| file.puts YAML.dump(game)}
    puts "Game saved. Thanks for playing"
  end

  def choose_saved_game
    puts "Which game would you like to play?"
    puts "#{Dir.glob('*/*.yml').map{ |s| File.basename(s, ".yml")}.join(",\n")}"
    input = gets.chomp.downcase
    load_game(input)
  end

  def load_game(filename)
    file = File.open("saved_games/#{filename}.yml", "r")
    data = file.read
    f = YAML::safe_load(data, permitted_classes: [Game, HumanPlayer])
    puts "Welcome back #{f.player}."
    @secret_word = f.secret_word
    @ltrs_guessed = f.ltrs_guessed
    @player = f.player
    @word_progress = f.word_progress
    @turn = f.turn
    puts "#{@word_progress.join}"
    puts "Incorrect letters: #{@ltrs_guessed.join}"
    File.delete("saved_games/#{filename}.yml")
  end

end

class Game
  include Display
  include GameLogic
  include SavedGames
  attr_reader :player, :secret_word
  attr_accessor :ltrs_guessed, :word_progress, :turn

  def initialize
      if play_from_saved_game()
        return
      else  
        @ltrs_guessed = []
        @player = HumanPlayer.new
        @turn = 6
        puts "Welcome, #{@player}."
        @secret_word = populate_dictionary.split("")
        @word_progress = Array.new(@secret_word.length, " __ ")
        puts "The secret word is #{@secret_word.length} letters long."
        puts "#{@word_progress.join}\n"  
      end  
  end

  def play
    loop do
      puts "----#{@turn} turns left---- If you'd like to save this game enter 'Save'."
      current_guess = HumanPlayer.make_guess(@ltrs_guessed)
      if current_guess == 'save'
        save_game(self)
        break
      end  
      update_word_progress(@secret_word, current_guess, @word_progress)
      if won?(@secret_word, @word_progress, @player) == true
        play_again()
        break
      end  
      if update_ltrs_guessed(@secret_word, current_guess, @ltrs_guessed) == true
        @turn -=1
      end  
      if @turn == 0
        lost(@secret_word, @player)
        play_again()
        break
      end  
    end  
  end

  def play_again
    loop do
      puts "Would you like to play again? Y or N"
      answer = gets.chomp.downcase
        if answer == "y"
          return Game.new.play
        elsif answer == "n" 
          puts "That's okay. Have a great summer!"
          return
        else 
          puts "I don't understand." 
        end
    end       

  end

end  

class HumanPlayer
  
  def initialize
    @name = get_name()
  end

  def get_name
    puts "What's your name?"
    name = gets.chomp.capitalize
    name
  end

  def self.make_guess(ltrs_guessed)
    loop do
      puts "Please guess a letter."
      current_guess = gets.chomp.downcase
        if current_guess == 'save'
          return current_guess 
        elsif ltrs_guessed.include?(current_guess)
          puts "You've already guessed that letter."
        elsif current_guess.length > 1 || current_guess.count('a-z').zero?
          puts "Incorrect input. Please try again."
        else
          return current_guess  
        end   
    end
       
  end

  def to_s
    @name
  end

end

Game.new.play
