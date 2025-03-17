class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo_list
  before_action :set_task, only: [:show, :update, :destroy]

  def index
    render json: { message: 'Tasks retrieved successfully', data: @todo_list.tasks }, status: :ok
  end
  

  def show
    render json: { message: 'Task retrieved successfully', data: @task }, status: :ok
  end


  def create
    task = @todo_list.tasks.build(task_params)
    if task.save
      render json: { message: 'Task created successfully', data: task }, status: :created
    else
      render json: { message: 'Task creation failed', errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def update
    if @task.update(task_params)
      render json: { message: 'Task updated successfully', data: @task }, status: :ok
    else
      render json: { message: 'Task update failed', errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def destroy
    if @task.destroy
      render json: { message: 'Task deleted successfully', data: @task }, status: :ok
    else
      render json: { message: 'Task deletion failed', errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end
  

  private

  def set_todo_list
    @todo_list = current_user.todo_lists.find_by(id: params[:todo_list_id])
    return render json: { message: 'Todo List not found' }, status: :not_found unless @todo_list
  end


  def set_task
    @task = @todo_list.tasks.find_by(id: params[:id])
    return render json: { message: 'Task not found' }, status: :not_found unless @task
  end
  

  def task_params
    params.require(:task).permit(:title, :description, :completed)
  end
end
