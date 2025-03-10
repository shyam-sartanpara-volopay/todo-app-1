class TodosController < ApplicationController
  before_action :authenticate_user!
  before_action :find_todo, only: %i[show update destroy]

  def index
    todos = current_user.todos
    render json: { todos: TasksRepresenter.new(todos).as_json }, status: :ok
  end

  def show
    render json: { todo: TaskRepresenter.new(@todo).as_json }, status: :ok
  end

  def create
    todo = current_user.todos.build(todo_params)
    if todo.save
      render json: { todo: TaskRepresenter.new(todo).as_json, message: 'Todo created successfully' }, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @todo.update(todo_params)
      render json: { todo: TaskRepresenter.new(@todo).as_json, message: 'Todo updated successfully' }, status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @todo.destroy
      render json: { message: 'Todo deleted successfully' }, status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def find_todo
    @todo = current_user.todos.find_by(id: params[:id])
    render json: { error: 'Todo not found' }, status: :not_found unless @todo
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :done)
  end
end
