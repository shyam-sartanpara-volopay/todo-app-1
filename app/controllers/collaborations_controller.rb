class CollaborationsController < ApplicationController
  before_action :set_todo_list, only: [:index, :create]
  before_action :authorize_todo_list, only: [:index, :create]
  before_action :set_collaboration, only: [:show, :update, :destroy]
  before_action :authorize_collaboration, only: [:show, :update, :destroy]

  def index
    collaborations = @todo_list.collaborations
    render json: { message: 'Collaborations retrieved successfully', data: collaborations }, status: :ok
  end

  def show
    render json: { message: 'Collaboration retrieved successfully', data: @collaboration }, status: :ok
  end

  def create
    collaboration = @todo_list.collaborations.build(collaboration_params)
    authorize collaboration

    if collaboration.save
      render json: { message: 'Collaboration added successfully', data: collaboration }, status: :created
    else
      render json: { message: 'Failed to add collaboration', errors: collaboration.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @collaboration.update(collaboration_params)
      render json: { message: 'Collaboration updated successfully', data: @collaboration }, status: :ok
    else
      render json: { message: 'Failed to update collaboration', errors: @collaboration.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @collaboration.destroy
      render json: { message: 'Collaboration removed successfully' }, status: :ok
    else
      render json: { message: 'Failed to remove collaboration', errors: @collaboration.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find_by(id: params[:todo_list_id])
    return render json: { message: 'Todo List not found' }, status: :not_found unless @todo_list
  end

  def set_collaboration
    @collaboration = Collaboration.find_by(id: params[:id])
    return render json: { message: 'Collaboration not found' }, status: :not_found unless @collaboration
  end

  def authorize_todo_list
    authorize @todo_list
  end

  def authorize_collaboration
    authorize @collaboration
  end

  def collaboration_params
    params.require(:collaboration).permit(:user_id)
  end
end
