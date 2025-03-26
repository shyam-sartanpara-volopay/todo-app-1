require 'rails_helper'

RSpec.describe 'Todos API', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:headers) { user.create_new_auth_token }
  let(:todo_list) { create(:todo_list, user: user) }
  let!(:todos) { create_list(:todo, 3, todo_list: todo_list) }
  let(:todo) { todos.first }
  let(:other_todo_list) { create(:todo_list, user: other_user) }
  let(:other_todo) { create(:todo, todo_list: other_todo_list) }
  let!(:other_user_headers) { other_user.create_new_auth_token }
  let!(:collaboration_user) { create(:user) }
  let(:collaboration_user_headers) { collaboration_user.create_new_auth_token }
  let!(:collaboration) { create(:collaboration, user: collaboration_user, todo_list: todo_list) }

  RSpec.shared_examples 'not_found error' do
    it 'returns not_found error' do
      subject
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq('error' => 'TodoList not found')
    end
  end

  describe 'GET /todo_lists/:todo_list_id/todos' do
    context 'when user is not authenticated' do
      it 'returns an unauthorized error' do
        get "/todo_lists/#{todo_list.id}/todos"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'returns all todos belonging to the user' do
        get "/todo_lists/#{todo_list.id}/todos", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(todos.size)
      end
    end

    context 'when collaborator tries access' do
      it 'returns all todos belonging to the todolist' do
        get "/todo_lists/#{todo_list.id}/todos", headers: collaboration_user_headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(todos.size)
      end
    end

    context 'when non collaborator tries access' do
      subject{ get "/todo_lists/#{todo_list.id}/todos", headers: other_user_headers }
      it_behaves_like 'not_found error'
    end
  end

  describe 'POST /todo_lists/:todo_list_id/todos' do
    let(:valid_params) { { todo: { title: 'New Todo', description: 'Sample description' } } }
    let(:invalid_params) { { todo: { title: '', description: '' } } }

    context 'when user is not authenticated' do
      it 'returns an unauthorized error' do
        post "/todo_lists/#{todo_list.id}/todos", params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when valid params are provided' do
      it 'creates a new todo' do
        expect do
          post "/todo_lists/#{todo_list.id}/todos", params: valid_params, headers: headers
        end.to change(Todo, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Todo created successfully')
      end
    end

    context 'when invalid params are provided' do
      it 'returns an error' do
        post "/todo_lists/#{todo_list.id}/todos", params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when collaborator tries access' do
      it 'creates a new todo' do
        post "/todo_lists/#{todo_list.id}/todos", params: valid_params, headers: collaboration_user_headers
        expect(response).to have_http_status(:created)
      end
    end

    context 'when non collaborator tries access' do
      subject{ post "/todo_lists/#{todo_list.id}/todos", params: valid_params, headers: other_user_headers }
      it_behaves_like 'not_found error'
    end
  end

  describe 'GET /todo_lists/:todo_list_id/todos/:id' do
    context 'when user is authenticated' do
      it 'returns the todo details' do
        get "/todo_lists/#{todo_list.id}/todos/#{todo.id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['id']).to eq(todo.id)
        expect(JSON.parse(response.body)['message']).to eq("Todo fetched successfully")
      end
    end

    context 'when user tries to access another user todo' do
      subject{ get "/todo_lists/#{other_todo_list.id}/todos/#{other_todo.id}", headers: headers }
      it_behaves_like 'not_found error'
    end

    context 'when collaborator tries access' do
      it 'returns the todo details' do
        get "/todo_lists/#{todo_list.id}/todos/#{todo.id}", headers: collaboration_user_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when non collaborator tries access' do
      subject{ get "/todo_lists/#{todo_list.id}/todos/#{todo.id}", headers: other_user_headers }
      it_behaves_like 'not_found error'
    end
  end

  describe 'PATCH /todo_lists/:todo_list_id/todos/:id' do
    let(:update_params) { { todo: { title: 'Updated Title' } } }

    context 'when user updates their own todo' do
      it 'updates the todo' do
        patch "/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:ok)
        json_data = JSON.parse(JSON.parse(response.body)['data'])
        expect(json_data['title']).to eq('Updated Title')
      end
    end

    context 'when user tries to update another user todo' do
      subject{ patch "/todo_lists/#{other_todo_list.id}/todos/#{other_todo.id}", params: update_params, headers: headers }
      it_behaves_like 'not_found error'
    end

    context 'when collaborator tries access' do
      it 'rcreates a new todo' do
        patch "/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: update_params, headers: collaboration_user_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when non collaborator tries access' do 
      subject{ patch "/todo_lists/#{todo_list.id}/todos/#{todo.id}", params: update_params, headers: other_user_headers }
      it_behaves_like 'not_found error'
    end
  end

  describe 'DELETE /todo_lists/:todo_list_id/todos/:id' do
    context 'when user deletes their own todo' do
      it 'deletes the todo' do
        expect do
          delete "/todo_lists/#{todo_list.id}/todos/#{todo.id}", headers: headers
        end.to change(Todo, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user tries to delete another user todo' do
      subject{ delete "/todo_lists/#{other_todo_list.id}/todos/#{other_todo.id}", headers: headers }
      it_behaves_like 'not_found error'
    end
  end

  context 'when collaborator tries access' do
    it 'deletes the todo' do
      delete "/todo_lists/#{todo_list.id}/todos/#{todos.second.id}", headers: collaboration_user_headers
      expect(response).to have_http_status(:ok)
    end
  end

  context 'when non collaborator tries access' do
    subject{ delete "/todo_lists/#{todo_list.id}/todos/#{todo.id}", headers: other_user_headers }
    it_behaves_like 'not_found error'
  end
end
