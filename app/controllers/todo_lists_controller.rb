class TodoListsController < ApplicationController
  before_action :set_todo_lists, only: :index
  before_action :set_todo_list, only: [:show, :update, :destroy]
  before_action :authorize_todo_list, only: [:show, :update, :destroy]

  def index
    render json: { message: 'Todo lists retrieved successfully', data: TodoListMiniSerializer.new(@todo_lists).serializable_hash }, status: :ok
  end

  def show
    render json: { message: 'Todo list retrieved successfully', data: TodoListDetailSerializer.new(@todo_list).serializable_hash }, status: :ok
  end

  def create
    @todo_list = current_user.todo_lists.build(todo_list_params)
    authorize @todo_list
    if @todo_list.save
      render json: { message: 'Todo list created successfully', data: TodoListDetailSerializer.new(@todo_list).serializable_hash }, status: :created
    else
      render json: { message: 'Todo list creation failed', errors: @todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @todo_list.update(todo_list_params)
      render json: { message: 'Todo list updated successfully', data: TodoListDetailSerializer.new(@todo_list).serializable_hash }, status: :ok
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
    @todo_lists = policy_scope(TodoList)
  end
  
  def set_todo_list
    @todo_list = TodoList.find(params[:id])
    authorize @todo_list
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Todo list not found' }, status: :not_found
  end
  
  def authorize_todo_list
    authorize @todo_list
  end
  
  def todo_list_params
    params.require(:todo_list).permit(:category, :status)
  end
end
