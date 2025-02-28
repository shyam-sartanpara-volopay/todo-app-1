class TasksController < ApplicationController
  before_action :set_task, only: [:show, :update, :destroy]

  
  def index
    tasks = Task.all
    render json: { message: 'Tasks retrieved successfully', tasks: tasks }, status: :ok
  end

  
  def show
    render json: { message: 'Task retrieved successfully', task: @task }, status: :ok
  end

 
  def create
    task = Task.new(task_params)
    if task.save
      render json: { message: 'Task created successfully', task: task }, status: :created
    else
      render json: { message: 'Task creation failed', errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  
  def update
    if @task.update(task_params)
      render json: { message: 'Task updated successfully', task: @task }, status: :ok
    else
      render json: { message: 'Task update failed', errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def destroy
    if @task.destroy
      render json: { message: 'Task deleted successfully' }, status: :ok
    else
      render json: { message: 'Task deletion failed' }, status: :unprocessable_entity
    end
  end


  private
  
  def set_task
    @task = Task.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Task not found' }, status: :not_found
  end

  def task_params
    params.require(:task).permit(:title, :description, :completed)
  end
end
