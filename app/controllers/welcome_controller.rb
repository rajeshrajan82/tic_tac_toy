class WelcomeController < ApplicationController
  before_filter :set_default_values, :only => [:index]
  before_filter :initialize_value, :only => [:create]

  GAME_SET = [9, 16, 25]
  
  def index
    Tictactoe.new(:total => 0, :pass => 0, :fail => 0, :user => current_user).save if current_user.tictactoe.nil?
  end
  
  def game_change
    if GAME_SET.include? (params[:id].to_i)
      session[:game_id] = params[:id].to_i
    end
    redirect_to root_path
  end
  
  def create
    add_user_picked_value(params[:id])
    @user_won = TicTacToeRule.is_user_won?(@user_picked_values, @possible_way_set)
    get_host_choose_number unless @user_won
    game_over if @user_won || @host_won
    
    respond_to do | format|
      msg = { :status => "ok", :message => "Success!", :host_choose_numbser => @choose_number, :user_won => @user_won, :host_won => @host_won || false }
      format.json {render :json => msg}
    end
  end
  
  def add_user_picked_value(id)
    @user_picked_values << id.to_i
    update_user_values
    @valid_numbers = (1..@game_id.to_i).to_a if @valid_numbers.nil?
    @valid_numbers.to_a.delete(id.to_i)
    update_valid_numbers
  end

  def get_host_choose_number
    @choose_number = possible_number_to_win
    unless @choose_number.nil?
      @valid_numbers.delete(@choose_number.to_i)
      update_valid_numbers
      @host_picked_values << @choose_number
      update_host_values
    end
    @host_won = TicTacToeRule.find_possiblity?(@host_picked_values, @choose_number, @possible_way_set)
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
      record = TicTacToeRule.get_block_number(@user_picked_values, @host_picked_values, @possible_way_set, number) 
      return number if record >= (@game_value.to_i - 1)
    end
    get_possible_way_to_win
  end

  def get_possible_way_to_win
    possible_list = {}
    @valid_numbers.each do |number|
      result = TicTacToeRule.get_win_possiblity_number(@valid_numbers, @host_picked_values, @possible_way_set, number)
      possible_list[number] = result
    end 
    TicTacToeRule.get_win_number(possible_list)
  end
  
  def game_over
    tictactoe = current_user.tictactoe
    tictactoe.pass = tictactoe.pass.to_i + 1 if @user_won
    tictactoe.fail = tictactoe.fail.to_i + 1 if @host_won
    tictactoe.total = tictactoe.total.to_i + 1
    tictactoe.save
  end
#  
  def get_values(key)
    Rails.cache.read(key)
  end

  def update_user_values
    session[:user_values] = @user_picked_values
  end
  
  def update_host_values
    session[:host_values] = @host_picked_values
  end
  
  def update_valid_numbers
    session[:valid_numbers] = @valid_numbers
  end
  
  def initialize_value
    @choose_number = nil
    @host_won = false
    
    @game_id = session[:game_id] ||= 9
    @valid_numbers = session[:valid_numbers] ||= nil
    @user_picked_values = session[:user_values] ||= []
    @host_picked_values = session[:host_values] ||= []
    @possible_way_set ||= get_values("#{@game_id}X")
    @game_value ||= get_game_value(@game_id)
  end
  
  
  def set_default_values
    Rails.cache.write("9X", TicTacToeRule::POSSIBLE_3X3_SET)
    Rails.cache.write("16X", TicTacToeRule::POSSIBLE_4X4_SET)
    Rails.cache.write("25X", TicTacToeRule::POSSIBLE_5X5_SET)
    
    session[:valid_numbers] = session[:user_values] = session[:host_values] = nil
    @game_id = session[:game_id] ||= 9
    @possible_way_set = get_values("#{@game_id}X")
    @game_value = get_game_value(@game_id)
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
