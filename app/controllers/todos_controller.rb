class TodosController < ApplicationController
  before_action :fetch_todo_list
  before_action :authorize_todo_list
  before_action :set_todo, only: %i[show update destroy]

  def index
    todos = @todo_list.todos
    render json: todos, status: :ok
  end

  def show
    render json: @todo, status: :ok
  end

  def create
    todo = @todo_list.todos.build(todo_params)
    if todo.save
      render json: { todo:, message: 'Todo created successfully' }, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @todo.update(todo_params)
      render json: { todo: @todo, message: 'Todo updated successfully' }, status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @todo.destroy
      render json: { message: 'Todo deleted successfully' }, status: :ok
    else
      render json: { errors: @todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def todo_params
    params.require(:todo).permit(:title, :description, :done)
  end

  def fetch_todo_list
    @todo_list = TodoList.find_by(id: params[:todo_list_id])
    render json: { error: 'No TodoList exists' }, status: :not_found unless @todo_list
  end

  def authorize_todo_list
    authorize @todo_list, :access_todos?
  end

  def set_todo
    @todo = @todo_list.todos.find_by(id: params[:id])

    render json: { error: 'Todo not found' }, status: :not_found unless @todo
  end
end
