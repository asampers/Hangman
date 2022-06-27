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

class Game
  include Display
  include GameLogic
  attr_reader :player, :secret_word
  attr_accessor :ltrs_guessed, :word_progress

  def initialize
    @ltrs_guessed = []
    @player = HumanPlayer.new
    puts "The player is #{@player}"
    @secret_word = populate_dictionary.split("")
    puts "The Secret word is #{@secret_word}"
    @word_progress = Array.new(@secret_word.length, " __ ")
    puts "The secret word is #{@secret_word.length} letters long."
    puts "#{@word_progress.join}\n"
  end

  def play
    turn = 6
    while turn > 0
      puts "----#{turn} turns left----"
      current_guess = HumanPlayer.make_guess(@secret_word)
      update_word_progress(@secret_word, current_guess, @word_progress)
      if won?(@secret_word, @word_progress, @player, turn)
        then break
      end  
      update_ltrs_guessed(@secret_word, current_guess, @ltrs_guessed)
      turn -= 1
      if turn == 0
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