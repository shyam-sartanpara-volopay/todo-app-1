class TodosController < ApplicationController
  before_action :fetch_todo_list
  before_action :set_todo, only: %i[show update destroy]

  def index
    authorize @todo_list, policy_class: TodoPolicy 
    todos = @todo_list.todos
    render json: TodoSerializer.new(todos).serialize, status: :ok
  end

  def show
    authorize @todo_list, policy_class: TodoPolicy 
    render json: { message: "Todo fetched successfully", data: TodoDetailSerializer.new(@todo).serializable_hash}, status: :ok
  end

  def create
    todo = @todo_list.todos.build(todo_params)
    if todo.save
      render json: { message: 'Todo created successfully', data: TodoSerializer.new(todo).serialize}, status: :created
    else
      render json: { errors: todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @todo_list, policy_class: TodoPolicy 
    if @todo.update(todo_params)
      render json: { message: 'Todo updated successfully',data: TodoSerializer.new(@todo).serialize }, status: :ok
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @todo_list, policy_class: TodoPolicy 
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
    @todo_list = policy_scope(TodoList).find_by(id: params[:todo_list_id])
    render json: { error: 'TodoList not found' }, status: :not_found unless @todo_list
  end

  def set_todo
    @todo = @todo_list.todos.find_by(id: params[:id])

    render json: { error: 'Todo not found' }, status: :not_found unless @todo
  end
end
