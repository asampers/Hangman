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
      if current_guess[i] == secret_word[i]
        word_progress[i] = "#{ltr} "
        current_guess[i] = "+"
      end
    end 
    puts "Game progress: #{word_progress.join}"
    return current_guess   
  end

  def update_ltrs_guessed(secret_word, current_guess, ltrs_guessed)
    current_guess.each_with_index.map do |ltr, i|
      if secret_word.include?(current_guess[i])
        current_guess[i] = "+"
      end
    end 
    current_guess.delete("+") 
    ltrs_guessed << (current_guess - ltrs_guessed)
    ltrs_guessed.flatten!.uniq!
    puts "Incorrect letters: #{ltrs_guessed.join.to_s.upcase}"
  end

  def won?(secret_word, word_progress, player, turn)
    if secret_word.join == word_progress.join.delete(" ")
      puts "Secret word: #{secret_word.join}"
      puts "Congratulations, #{player}! You guessed correctly!"
      turn -= 6
      return turn
    end 
  end  

  def lost(secret_word, player)
    puts "Sorry, #{player}. You ran out of guesses. The word was '#{secret_word.join}'."   
  end
end

module SavedGames

  def save_game(game)
    puts "...saving game..."
    Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
    filename = "saved_games/game#{Dir.glob('../saved_games/*').length+1}.yml"

    File.open(filename, 'w') {|file| file.puts YAML.dump(game)}
    puts "Game saved. Thanks for playing"
  end

  def choose_saved_game
    puts "Which game would you like to play?"
    puts "#{Dir.glob('*/*.yml').join(",\n")}"
    input = gets.chomp
    load_game(input)
  end

  def load_game(filename)
    file = File.open("#{filename}", "r")
    data = file.read
    f = YAML::safe_load(data, permitted_classes: [Game, HumanPlayer])
    puts "Welcome back #{f.player}."
    @secret_word = f.secret_word
    @ltrs_guessed = f.ltrs_guessed
    @player = f.player
    @word_progress = f.word_progress
    @turn = f.turn
  end

end

class Game
  include Display
  include GameLogic
  include SavedGames
  attr_reader :player, :secret_word
  attr_accessor :ltrs_guessed, :word_progress, :turn

  def initialize
    if Dir.glob('saved_games/*').length > 0
      puts "Would you like to play from a saved game? Y or N"
      answer = gets.chomp.upcase
      if answer == "Y"
        choose_saved_game()
        play()
        return
      end
    end 
    @ltrs_guessed = []
    @player = HumanPlayer.new
    @turn = 6
    puts "The player is #{@player}"
    @secret_word = populate_dictionary.split("")
    puts "The Secret word is #{@secret_word}"
    @word_progress = Array.new(@secret_word.length, " __ ")
    puts "The secret word is #{@secret_word.length} letters long."
    puts "#{@word_progress.join}\n"    
  end

  def play
    while @turn != 0
      puts "----#{@turn} turns left---- If you'd like to save this game enter 'S'."
      current_guess = HumanPlayer.make_guess(@secret_word)
      if current_guess == 's'
        save_game(self)
        break
      end  
      update_word_progress(@secret_word, current_guess, @word_progress)
      if won?(@secret_word, @word_progress, @player, @turn)
        then break
      end  
      update_ltrs_guessed(@secret_word, current_guess, @ltrs_guessed)
      @turn -= 1
      if @turn == 0
        lost(@secret_word, @player)
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

  def self.make_guess(secret_word)
    loop do
      puts "Please guess a #{secret_word.length} letter word."
      current_guess = gets.chomp.downcase
        if current_guess.length == secret_word.length
          return current_guess = Array(current_guess.split('') )  
        elsif current_guess == 's'
          return current_guess     
        else
          puts "That's not the right amount of letters. Please guess a #{secret_word.length} letter word."
        end 
    end
       
  end

  def to_s
    @name
  end

end

Game.new.play
