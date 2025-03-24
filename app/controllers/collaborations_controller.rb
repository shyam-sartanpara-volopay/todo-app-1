class CollaborationsController < ApplicationController
  before_action :fetch_todo_list

  def index
    authorize Collaboration.new(todo_list: @todo_list), :index? 
    collaborations = @todo_list.collaborations
    render json: collaborations, status: :ok
  end

  def create
    authorize Collaboration.new(todo_list: @todo_list), :create? 

    user = User.find_by(email: params[:email])
    return render json: { error: 'User not found' }, status: :not_found unless user

    collaboration = @todo_list.collaborations.build(user_id: user.id)

    if collaboration.save
      render json: { collaboration:, message: 'Collaboration created successfully' }, status: :created
    else
      render json: { errors: collaboration.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize Collaboration.new(todo_list: @todo_list), :destroy?
    collaboration = @todo_list.collaborations.find_by(user_id: params[:id])

    if collaboration.nil?
      render json: { error: 'Collaboration not found' }, status: :not_found
      return
    end

    if collaboration.destroy
      render json: { message: 'Collaboration deleted successfully' }, status: :ok
    else
      render json: { errors: collaboration.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def fetch_todo_list
    @todo_list = policy_scope(TodoList).find_by(id: params[:todo_list_id])
    render json: { error: 'No TodoList exists' }, status: :not_found unless @todo_list
  end
end
