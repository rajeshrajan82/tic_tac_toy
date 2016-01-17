class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
       
  has_one :tictactoe
  
  def is_won?(picked_numbers)
    TicTacToeRule::POSSIBLE_WAY_SET.each do |possible_set|
      possible_values = possible_set.select{|number| picked_numbers.include?(number)}
      return true if possible_values.size == possible_set.size
    end
    false
  end
       
end
