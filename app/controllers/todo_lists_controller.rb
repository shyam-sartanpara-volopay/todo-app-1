class TodoListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_lists, only: :index
  before_action :set_todo_list, only: [:show, :update, :destroy]
  before_action :authorize_todo_list, only: [:show, :update, :destroy]

  
  def index
    render json: { message: 'Todo lists retrieved successfully', data: @todo_lists.as_json(include: :tasks) }, status: :ok
  end

  def show
    render json: { message: 'Todo list retrieved successfully', data: @todo_list.as_json(include: :tasks) }, status: :ok
  end

  def create
    @todo_list = current_user.todo_lists.build(todo_list_params)
    authorize_todo_list(@todo_list)
    if @todo_list.save
      render json: { message: 'Todo list created successfully', data: @todo_list.as_json(include: :tasks) }, status: :created
    else
      render json: { message: 'Todo list creation failed', errors: @todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @todo_list.update(todo_list_params)
      render json: { message: 'Todo list updated successfully', data: @todo_list.as_json(include: :tasks) }, status: :ok
    else
      render json: { message: 'Todo list update failed', errors: @todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @todo_list.destroy
      render json: { message: 'Todo list deleted successfully' }, status: :ok
    else
      render json: { message: 'Todo list deletion failed' }, status: :unprocessable_entity
    end
  end


  private

  def set_todo_lists
    @todo_lists = TodoList
                    .left_joins(:collaborations)
                    .where("todo_lists.user_id = ? OR collaborations.user_id = ?", current_user.id, current_user.id)
                    .distinct
                    .includes(:tasks)
  end

  def set_todo_list
    @todo_list = TodoList
                   .left_joins(:collaborations)
                   .where("todo_lists.user_id = ? OR collaborations.user_id = ?", current_user.id, current_user.id)
                   .distinct
                   .includes(:tasks)
                   .find_by!(id: params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Todo list not found' }, status: :not_found
  end

  def authorize_todo_list(todo_list = @todo_list)
    authorize todo_list
  end
  
  def todo_list_params
    params.require(:todo_list).permit(:category, :status)
  end
end
