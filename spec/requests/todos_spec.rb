require 'rails_helper'

RSpec.describe 'Todos API', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:headers) { user.create_new_auth_token }
  let!(:todos) { create_list(:todo, 3, user: user) }
  let(:todo) { todos.first }

  describe 'GET /todos' do
    context 'when user is not authenticated' do
      it 'returns an unauthorized error' do
        get '/todos'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authenticated' do
      it 'returns all todos belonging to the user' do
        get '/todos', headers: headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /todos/:id' do
    context 'when user is not authenticated' do
      it 'returns an unauthorized error' do
        get "/todos/#{todo.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when todo belongs to the user' do
      it 'returns the requested todo' do
        get "/todos/#{todo.id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['todo']['title']).to eq(todo.title)
      end
    end

    context 'when todo does not belong to the user' do
      let!(:other_todo) { create(:todo, user: other_user) }

      it 'returns a not found error' do
        get "/todos/#{other_todo.id}", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /todos' do
    let(:valid_params) { { todo: { title: 'New Todo', description: 'Sample description' } } }
    let(:invalid_params) { { todo: { title: '', description: '' } } }

    context 'when user is not authenticated' do
      it 'returns an unauthorized error' do
        post '/todos', params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when valid params are provided' do
      it 'creates a new todo' do
        expect {
          post '/todos', params: valid_params, headers: headers
        }.to change(user.todos, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'when invalid params are provided' do
      it 'returns an error' do
        post '/todos', params: invalid_params, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /todos/:id' do
    let(:update_params) { { todo: { title: 'Updated Title', description: 'Updated description' } } }

    context 'when user is not authenticated' do
      it 'returns an unauthorized error' do
        patch "/todos/#{todo.id}", params: update_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when todo belongs to the user' do
      it 'updates the todo' do
        patch "/todos/#{todo.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Todo updated successfully')
      end
    end

    context 'when todo does not belong to the user' do
      let!(:other_todo) { create(:todo, user: other_user) }

      it 'returns a not found error' do
        patch "/todos/#{other_todo.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /todos/:id' do
    context 'when user is not authenticated' do
      it 'returns an unauthorized error' do
        delete "/todos/#{todo.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when todo belongs to the user' do
      it 'deletes the todo' do
        expect { delete "/todos/#{todo.id}", headers: headers }.to change(user.todos, :count).by(-1)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when todo does not belong to the user' do
      let!(:other_todo) { create(:todo, user: other_user) }

      it 'returns a not found error' do
        delete "/todos/#{other_todo.id}", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
