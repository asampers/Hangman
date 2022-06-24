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
        word_progress[i] = "#{ltr}"
        current_guess.delete(ltr)
      end
    end 
    puts word_progress.join
    current_guess   
  end

  def update_ltrs_guessed(secret_word, current_guess, ltrs_guessed)
    current_guess.each_with_index.map do |ltr, i|
      if answer.include?(current_guess[i])
        current_guess.delete(ltr) 
      end
    end  
    current_guess
    ltrs_guessed << (current_guess - ltrs_guessed)
    puts ltrs_guessed.join
  end

  def won?(secret_word, current_guess, name)
    if secret_word.join == current_guess.join
      "Congratulations, #{name}! You guessed correctly!"
    end 
  end  

  def lost(secret_word, name)
    "Sorry, #{name}. You ran out of guesses. The word was '#{secret_word}'."   
  end
end

class Game
  include Display
  include GameLogic
  attr_reader :player, :secret_word
  attr_accessor :ltrs_guessed, :word_progress

  def initialize
    @ltrs_guessed = []
    @secret_word = populate_dictionary.split("")
    puts "The Secret word is #{@secret_word.join}"
    @word_progress = Array.new(@secret_word.length - 1, " __ ")
    puts "The word progress is #{@word_progress.join}"
    @player = HumanPlayer.new
    puts "The player is #{@player}"
  end

  def play
    turn = 6
    while turn > 0
      puts "#{turn} turns left"
      @current_guess = @player.make_guess
      puts "The current guess is #{@current_guess}"
      update_word_progress(@secret_word, @current_guess, @word_progress)
      update_ltrs_guessed(@secret_word, @current_guess, @ltrs_guessed)
      if won?(@secret_word, @current_guess, @player)
        return
      end  
      turn -= 1
    end 
    lost(@secret_word, @player)
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

  def make_guess
    loop do
      puts "Please guess a 5-12 letter word."
      current_guess = gets.chomp.downcase
        if current_guess.length > 4 && current_guess.length < 13
          break
        else
          "That's not the right amount of letters."
        end
      return current_guess = Array(current_guess.split('') )  
    end
           
  end

  def to_s
    @name
  end

end

Game.new.play