class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[show update destroy]

  def index
    todo_lists = current_user.todo_lists
    render json: todo_lists, status: :ok
  end

  def show
    render json: @todo_list, status: :ok
  end

  def create
    todo_list = current_user.todo_lists.build(todo_list_params)
    if todo_list.save
      render json: { todo_list: todo_list, message: 'Todo list created successfully' }, status: :created
    else
      render json: { errors: todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @todo_list.update(todo_list_params)
      render json: { todo_list: @todo_list, message: 'Todo list updated successfully' }, status: :ok
    else
      render json: { errors: @todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @todo_list.destroy
      render json: { message: 'Todo list deleted successfully' }, status: :ok
    else
      render json: { errors: @todo_list.errors.full_messages }
    end
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(:name)
  end

  def set_todo_list
    @todo_list = current_user.todo_lists.find_by(id: params[:id])
    render json: { error: 'TodoList not found' }, status: :not_found unless @todo_list
  end
end
