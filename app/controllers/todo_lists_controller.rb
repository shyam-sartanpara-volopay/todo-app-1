class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[show update destroy]

  def index
    todo_lists = policy_scope(TodoList)
    render json: TodoListSerializer.new(todo_lists).serialize, status: :ok
  end

  def show
    authorize @todo_list
    render json: { message: "Todolist fetched successfully", data: TodoListDetailSerializer.new(@todo_list).serializable_hash }, status: :ok
  end

  def create
    todo_list = current_user.todo_lists.build(todo_list_params)
    if todo_list.save
      render json: { message: 'Todolist created successfully', data: JSON.parse(TodoListSerializer.new(todo_list).serialize) }, status: :created
    else
      render json: { errors: todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @todo_list
    if @todo_list.update(todo_list_params)
      render json: { message: 'Todolist updated successfully',data: JSON.parse(TodoListSerializer.new(@todo_list).serialize) }, status: :ok
    else
      render json: { errors: @todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @todo_list
    if @todo_list.destroy
      render json: { message: 'Todolist deleted successfully' }, status: :ok
    else
      render json: { errors: @todo_list.errors.full_messages }
    end
  end

  private

  def todo_list_params
    params.require(:todo_list).permit(:name, :status)
  end

  def set_todo_list
    @todo_list = policy_scope(TodoList).find_by(id: params[:id])
    render json: { error: 'TodoList not found' }, status: :not_found unless @todo_list
  end
end
