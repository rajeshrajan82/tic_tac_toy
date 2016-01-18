class WelcomeController < ApplicationController
  before_filter :initialize_value, :only => [:create]
  before_filter :set_cache_values, :only => [:index]
  GAME_SET = [9, 16, 25]
  
  def index
    Tictactoe.new(:total => 0, :pass => 0, :fail => 0, :user => current_user).save if current_user.tictactoe.nil?
  end
  
  def game_change
    if GAME_SET.include? (params[:id].to_i)
      Rails.cache.write("game", params[:id])
    end
    redirect_to root_path
  end
  
  def create
    add_picked_value(params[:id])
    user_won = is_user_won?
    unless user_won
      system_pick_value
      system_won = TicTacToeRule.find_possiblity?(@host_picked_values, @choose_number, @possible_way_set)
    end
    game_over(user_won, system_won) if user_won || system_won
    
    respond_to do | format|
      msg = { :status => "ok", :message => "Success!", :host_choose_numbser => @choose_number, :user_won => user_won, :host_won => system_won || false }
      format.json {render :json => msg}
    end
  end
  
  def is_user_won?
    @possible_way_set.each do |possible_set|
      possible_values = possible_set.select{|number| @user_picked_values.include?(number)}
      return true if possible_values.size == possible_set.size
    end
    false
  end
  
  def add_picked_value(id)
    @user_picked_values << id.to_i
    set_picked_values("user_picked_values", @user_picked_values)
    @valid_numbers = (1..@gameId.to_i).to_a if @valid_numbers.nil?
    @valid_numbers.to_a.delete(id.to_i)
    set_valid_numbers("valid_numbers", @valid_numbers)
  end

  def system_pick_value
    @choose_number = possible_number_to_win
    unless @choose_number.nil?
      @valid_numbers.delete(@choose_number)
      set_valid_numbers("valid_numbers", @valid_numbers)
      @host_picked_values << @choose_number.to_i
      set_picked_values("host_picked_values", @host_picked_values)
    end
  end
  
  def possible_number_to_win
    @valid_numbers.each do |number|
      return number if TicTacToeRule.find_possiblity?(@host_picked_values, number, @possible_way_set)
    end
    possible_number_to_lose
  end

  def possible_number_to_lose
    @valid_numbers.each do |number|
      return number if TicTacToeRule.find_possiblity?(@user_picked_values, number, @possible_way_set)
    end
    get_a_number_to_block
  end

  def get_a_number_to_block
    @valid_numbers.each do |number|  
      record = 0
      @possible_way_set.each do |possible_set|          
        next if !possible_set.include?(number)
        record += 1 if !possible_set.select {|element| @user_picked_values.include?(element)}.empty? &&
          possible_set.select {|element| @host_picked_values.include?(element)}.empty?
      end 
      return number if record >= (@game_value.to_i - 1)
    end
    get_possible_way_to_win
  end

  def get_possible_way_to_win
    possible_list = {}
    @valid_numbers.each do |number|
      result = 0   
      
      @possible_way_set.each do |possible_set|      
        next unless possible_set.include?(number)        
        possible_set.each do |element|
          next_val = (!@valid_numbers.include?(element) && !@host_picked_values.include?(element)) ? -1 : 1
          result = result + next_val
        end
      end
      possible_list[number] = result
    end 
    TicTacToeRule.get_win_number(possible_list)
  end
  
  def game_over(user_won, system_won)
    tictactoe = current_user.tictactoe
    tictactoe.pass = tictactoe.pass.to_i + 1 if user_won
    tictactoe.fail = tictactoe.fail.to_i + 1 if system_won
    tictactoe.total = tictactoe.total.to_i + 1
    tictactoe.save
  end
  
  def get_values(key)
    Rails.cache.read(key)
  end
  
  def set_picked_values(key, picked)
    Rails.cache.write(key, picked)
  end
  
  def set_valid_numbers(key, valid_numbers)
    Rails.cache.write(key, valid_numbers)
  end
  
  def initialize_value
    @user_picked_values = get_values("user_picked_values")
    @host_picked_values = get_values("host_picked_values")
    @valid_numbers = get_values("valid_numbers")
    @gameId = get_values("game")
    
    @possible_way_set = get_values("#{@gameId}X")
    @game_value = get_game_value(@gameId)
    
    @user_picked_values ||= []
    @host_picked_values ||= []
    @choose_number = nil
  end
  
  
  def set_cache_values
    @gameId = get_values("game")
    Rails.cache.write("game", @gameId ||= 9)
    Rails.cache.write("9X", TicTacToeRule::POSSIBLE_3X3_SET)
    Rails.cache.write("16X", TicTacToeRule::POSSIBLE_4X4_SET)
    Rails.cache.write("25X", TicTacToeRule::POSSIBLE_5X5_SET)
    
    Rails.cache.write("user_picked_values", nil)
    Rails.cache.write("host_picked_values", nil)
    Rails.cache.write("valid_numbers", nil)
  end
  
  def get_game_value(id)
    case :id
    when "25"
      return 5
    when "16"
      return 4
    else
      return 3
    end
  end
end
