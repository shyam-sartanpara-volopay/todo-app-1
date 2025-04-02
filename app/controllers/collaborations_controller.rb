class CollaborationsController < ApplicationController
  before_action :fetch_todo_list

  def index
    authorize @todo_list, policy_class: CollaborationPolicy
    collaborations = @todo_list.collaborations
    render json: CollaborationSerializer.new(collaborations).serialize, status: :ok
  end

  def create
    authorize @todo_list, policy_class: CollaborationPolicy

    user = User.find_by(email: params[:email])
    return render json: { error: 'User not found' }, status: :not_found unless user

    collaboration = @todo_list.collaborations.build(user_id: user.id)

    if collaboration.save
      render json: { message: 'Collaboration created successfully', data: CollaborationSerializer.new(collaboration).serialize}, status: :created
    else
      render json: { errors: collaboration.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @todo_list, policy_class: CollaborationPolicy
    collaboration = @todo_list.collaborations.find_by(user_id: params[:id])

    if collaboration.nil?
      render json: { error: 'User not found' }, status: :not_found
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
    render json: { error: 'TodoList not found' }, status: :not_found unless @todo_list
  end
end
