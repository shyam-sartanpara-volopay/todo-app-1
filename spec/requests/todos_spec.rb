require 'rails_helper'

RSpec.describe 'Todos API', type: :request do
  describe 'GET /todos' do
    let!(:todo) { FactoryBot.create(:todo, title: 'Test Sample') }

    context 'when there are todos present' do
      it 'returns all todos with status ok' do
        get '/todos'
        json_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json_response.size).to eq(1)
      end
    end
    context 'when fetching a todo by id' do
      it 'returns the correct todo' do
        get "/todos/#{todo.id}"
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['todo']['title']).to eq('Test Sample')
      end
    end

    context 'when fetching a unavilable todo by id' do
      it 'returns error' do
        get '/todos/9999'
        expect(response).to have_http_status(:not_found)

        json_response = JSON.parse(response.body)
        expect(json_response).to eq({ 'error' => 'Todo not found' })
      end
    end

    context 'when there are no todos' do
      before { Todo.delete_all }

      it 'returns an empty array' do
        get '/todos'
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({ 'todos' => [] })
      end
    end
  end

  describe 'POST /todos' do
    let(:valid_params) { { todo: { title: 'Test Sample', description: 'description for sample testing ' } } }
    let(:invalid_params) { { todo: { title: '', description: '' } } }

    context 'create a todo with valid params' do
      it 'sucessful creation of todo ' do
        expect { post '/todos', params: valid_params }.to change { Todo.count }.by(1)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Todo created successfully')
        expect(json_response['todo']['title']).to eq('Test Sample')
      end
    end

    context 'create a todo with missing params' do
      it 'unsucessful creation of todo ' do
        expect { post '/todos', params: invalid_params }.to change { Todo.count }.by(0)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response).to eq({ 'errors' => ["Title can't be blank"] })
      end
    end

    context 'when creating a todo with a duplicate title' do
      it 'fails to create a duplicate todo' do
        expect { post '/todos', params: valid_params }.to change { Todo.count }.by(1)
        expect { post '/todos', params: valid_params }.to change { Todo.count }.by(0)
        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response).to eq({ 'errors' => ['Title has already been added'] })
      end
    end
  end

  describe 'PATCH /todos' do
    let!(:todo) { FactoryBot.create(:todo, title: 'Test Sample') }
    let(:todo_id) { todo.id }

    context 'when todo is not completed' do
      it 'Mark as completed' do
        patch "/todos/#{todo_id}"

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Todo marked as completed')
        expect(json_response['todo']['status']).to eq('Done')
      end
    end

    context 'when todo is already completed' do
      it 'returns a message that the todo is already completed' do
        patch "/todos/#{todo_id}"
        patch "/todos/#{todo_id}"
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Todo is already completed')
      end
    end

    context 'Invalid request with unknown id' do
      it 'returns a not found error' do
        put '/todos/999999'
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({ 'error' => 'Todo not found' })
      end
    end
  end

  describe 'DELETE /todos', type: :request do
    let!(:undone_todo) { FactoryBot.create(:todo, title: 'Undone todo') }
    # let!(:completed_todo) { FactoryBot.create(:todo, title: 'Completed Todo', done: true) }
    context 'when todo exists and is undone' do
      it 'delete operation done sucessfully' do
        expect { delete "/todos/#{undone_todo.id}" }.to change { Todo.count }.by(-1)
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Todo deleted successfully')
      end
    end

    # context 'when the todo is already completed' do
    #   it 'returns an error that completed todos cannot be deleted' do
    #     expect { delete "/todos/#{completed_todo.id}" }.to change { Todo.count }.by(0)
    #     expect(response).to have_http_status(:forbidden)
    #     json_response = JSON.parse(response.body)
    #     expect(json_response['error']).to eq('Completed todos cannot be deleted')
    #   end
    # end

    context 'when the todo does not exist' do
      it 'returns a not found error' do
        delete '/todos/999999'
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response).to eq({ 'error' => 'Todo not found' })
      end
    end
  end
end
