class TasksRepresenter
  def initialize(todos)
    @todos = todos
  end

  def as_json
    todos.map do |todo|
      {
        id: todo.id,
        title: todo.title,
        description: todo.description,
        status: checker(todo.done)
      }
    end
  end

  private

  attr_reader :todos

  def checker(done)
    done ? 'Done' : 'Undone'
  end
end
