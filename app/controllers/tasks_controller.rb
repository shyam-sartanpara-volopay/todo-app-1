class TasksController < ApplicationController
  before_action :set_todo_list, only: [:index, :create]
  before_action :authorize_todo_list, only: [:index]
  before_action :set_task, only: [:show, :update, :destroy]
  before_action :authorize_task, only: [:show, :update, :destroy]

  def index
    tasks = policy_scope(Task).where(todo_list_id: @todo_list.id)
    render json: { message: 'Tasks retrieved successfully', data: TaskSerializer.new(tasks).serializable_hash }, status: :ok
  end

  def show
    render json: { message: 'Task retrieved successfully', data: TaskSerializer.new(@task).serializable_hash }, status: :ok
  end

  def create
    @task = @todo_list.tasks.build(task_params)
    authorize @task

    if @task.save
      render json: { message: 'Task created successfully', data: TaskSerializer.new(@task).serializable_hash }, status: :created
    else
      render json: { message: 'Task creation failed', errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render json: { message: 'Task updated successfully', data: TaskSerializer.new(@task).serializable_hash }, status: :ok
    else
      render json: { message: 'Task update failed', errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @task.destroy
      render json: { message: 'Task deleted successfully' }, status: :ok
    else
      render json: { message: 'Task deletion failed', errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_todo_list
    @todo_list = policy_scope(TodoList).find_by(id: params[:todo_list_id])
    return render json: { message: 'Todo list not found' }, status: :not_found unless @todo_list
  end
  
  def set_task
    @task = Task.find(params[:id])
    authorize @task
  rescue ActiveRecord::RecordNotFound
    render json: { message: 'Task not found' }, status: :not_found
  end

  def authorize_todo_list
    authorize @todo_list
  end

  def authorize_task
    authorize @task
  end

  def task_params
    params.require(:task).permit(:title, :description, :completed)
  end
end

