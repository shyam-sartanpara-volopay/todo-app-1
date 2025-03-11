class TaskRepresenter
  def initialize(todo)
    @todo = todo
  end

  def as_json
    {
      id: todo.id,
      title: todo.title,
      description: todo.description,
      status: checker
    }
  end

  private

  attr_reader :todo

  def checker
    todo.done ? 'Done' : 'Undone'
  end
end
