class TodoListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_list, only: [:show, :update, :destroy]

  
  def index
    todo_lists = current_user.todo_lists.includes(:tasks)
    render json: { message: 'Todo lists retrieved successfully', data: format_todo_lists(todo_lists) }, status: :ok
  end

  
  def show
    render json: { message: 'Todo list retrieved successfully', data: format_todo_list(@todo_list) }, status: :ok
  end

  
  def create
    todo_list = current_user.todo_lists.build(todo_list_params)

    if todo_list.save
      render json: { message: 'Todo list created successfully', data: format_todo_list(todo_list) }, status: :created
    else
      render json: { message: 'Todo list creation failed', errors: todo_list.errors.full_messages }, status: :unprocessable_entity
    end
  end

  
  def update
    if @todo_list.update(todo_list_params)
      render json: { message: 'Todo list updated successfully', data: format_todo_list(@todo_list) }, status: :ok
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

  def set_todo_list
    @todo_list = current_user.todo_lists.includes(:tasks).find_by(id: params[:id])
    return render json: { message: 'Todo list not found' }, status: :not_found unless @todo_list
  end

  
  def todo_list_params
    params.require(:todo_list).permit(:category)
  end

  
  def format_todo_list(todo_list)
    {
      id: todo_list.id,
      category: todo_list.category,
      tasks: todo_list.tasks.map do |task|
        {
          id: task.id,
          title: task.title,
          description: task.description,
          completed: task.completed,
          created_at: task.created_at,
          updated_at: task.updated_at
        }
      end
    }
  end

  
  def format_todo_lists(todo_lists)
    todo_lists.map { |todo_list| format_todo_list(todo_list) }
  end
end
