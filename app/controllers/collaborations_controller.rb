class CollaborationsController < ApplicationController
  before_action :fetch_todo_list
  before_action :authorize_collaboration

  def index
    collaborations = @todo_list.collaborations
    render json: collaborations, status: :ok
  end

  def create
    if @todo_list.user_id == params[:user_id].to_i
      render json: { error: 'Owner cannot be a collaborator' }, status: :unprocessable_entity
      return
    end

    collaboration = @todo_list.collaborations.build(user_id: params[:user_id])

    if collaboration.save
      render json: { collaboration:, message: 'Collaboration created successfully' }, status: :created
    else
      render json: { errors: collaboration.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { error: 'User is already a collaborator' }, status: :unprocessable_entity
  end

  def destroy
    collaboration = @todo_list.collaborations.find_by(user_id: params[:id])

    if collaboration.nil?
      render json: { error: 'Collaboration not found' }, status: :not_found
    elsif collaboration.destroy
      render json: { message: 'Collaboration deleted successfully' }, status: :ok
    else
      render json: { errors: collaboration.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def fetch_todo_list
    @todo_list = TodoList.find_by(id: params[:todo_list_id])
    render json: { error: 'No TodoList exists' }, status: :not_found unless @todo_list
  end

  def authorize_collaboration
    authorize @todo_list, :access_collaboration?
  end
end
