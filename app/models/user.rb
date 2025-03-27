# frozen_string_literal: true

class User < ActiveRecord::Base

  extend Devise::Models

  has_many :todo_lists, dependent: :destroy
  has_many :collaborations, dependent: :destroy
  has_many :shared_todo_lists, through: :collaborations, source: :todo_list
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User
end
