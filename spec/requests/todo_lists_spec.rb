require 'rails_helper'

RSpec.describe 'TodoLists API', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:headers) { user.create_new_auth_token }
  let!(:todo_lists) { create_list(:todo_list, 3, user: user) }
  let(:todo_list) { todo_lists.first }
  let(:other_todo_list) { create(:todo_list, user: other_user) }

  describe 'GET /todo_lists' do
    context 'when user is not authenticated' do
      it 'returns unauthorized error' do
        get '/todo_lists'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is authenticated' do
      it 'returns all todo lists of the user' do
        get '/todo_lists', headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(todo_lists.size)
      end
    end
  end

  describe 'GET /todo_lists/:id' do
    context 'when user is authenticated' do
      it 'returns the todo list details' do
        get "/todo_lists/#{todo_list.id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(todo_list.id)
      end
    end

    context 'when user tries to access another user todo list' do
      it 'returns not found' do
        get "/todo_lists/#{other_todo_list.id}", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /todo_lists' do
    let(:valid_params) { { todo_list: attributes_for(:todo_list) } }
    let(:invalid_params) { { todo_list: { name: '' } } }

    context 'when user is not authenticated' do
      it 'returns unauthorized error' do
        post '/todo_lists', params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when user is authenticated' do
      it 'creates a new todo list successfully' do
        expect do
          post '/todo_lists', params: valid_params, headers: headers
        end.to change(TodoList, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Todo list created successfully')
      end

      it 'returns errors for invalid parameters' do
        post '/todo_lists', params: invalid_params, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
      end
    end
  end

  describe 'PUT /todo_lists/:id' do
    let(:update_params) { { todo_list: { name: 'Updated Name' } } }

    context 'when user updates their own todo list' do
      it 'updates the todo list' do
        put "/todo_lists/#{todo_list.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['todo_list']['name']).to eq(update_params[:todo_list][:name])
      end
    end

    context 'when user tries to update another user todo list' do
      it 'returns not found' do
        put "/todo_lists/#{other_todo_list.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /todo_lists/:id' do
    context 'when user deletes their own todo list' do
      it 'deletes the todo list' do
        expect do
          delete "/todo_lists/#{todo_list.id}", headers: headers
        end.to change(TodoList, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user tries to delete another user todo list' do
      it 'returns not found' do
        delete "/todo_lists/#{other_todo_list.id}", headers: headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
