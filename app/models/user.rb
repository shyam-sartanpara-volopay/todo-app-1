# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  has_many :todo_lists, dependent: :destroy # as user.id is used in todo_lists table
  # dependent: :destroy --> when the parent model is deleted, all data in dependent models get deleted
  has_many :collaborations, dependent: :destroy # as user.id is used in collaborations table
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User
end
