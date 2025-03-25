require 'rails_helper'

RSpec.describe 'TodoLists API', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:headers) { user.create_new_auth_token }
  let!(:todo_lists) { create_list(:todo_list, 3, user: user) }
  let(:todo_list) { todo_lists.first }
  let!(:other_todo_list) { create(:todo_list, user: other_user) }
  let!(:other_user_headers) { other_user.create_new_auth_token }
  let!(:collaboration_user) { create(:user) }
  let(:collaboration_user_headers) { collaboration_user.create_new_auth_token }
  let!(:collaboration) { create(:collaboration, user: collaboration_user, todo_list: todo_list) }

  RSpec.shared_examples 'authentication error' do 
    it 'returns authentication error' do
      subject
      expect(response).to have_http_status(:unauthorized)
      expect(JSON.parse(response.body)).to eq('errors' => ['You need to sign in or sign up before continuing.'])
    end
  end

  RSpec.shared_examples 'authorization error' do
    it 'returns authorization error' do
      subject
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)).to eq('error' => 'You are not authorized to perform this action')
    end
  end

  RSpec.shared_examples 'successful creation' do |headers|
    it 'returns created' do
      subject
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['message']).to eq('Todo list created successfully')
   end
  end 

  RSpec.shared_examples 'not_found error' do
    it 'returns not_found error' do
      subject
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)).to eq('error' => 'TodoList not found')
    end
  end

  RSpec.shared_examples 'unprocessable_entity error' do |error_message|
    it 'returns unprocessable_entity error' do
      subject
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors'].first).to include(error_message)
    end
  end

  describe 'GET /todo_lists' do
    context 'when user is not authenticated' do
      subject{ get '/todo_lists' }
      it_behaves_like 'authentication error' 
    end

    context 'when user is the owner' do
      it 'returns all todo lists of the user' do
        get '/todo_lists', headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(todo_lists.size)
      end
    end

    context 'when user is not a collaborator' do
      it 'returns its own todolist under policy_scope' do
        get '/todo_lists', headers: other_user_headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body).size).to eq(other_user.todo_lists.count)
      end
    end
  end

  describe 'GET /todo_lists/:id' do
    context 'when user is not authenticated' do
      subject{ get "/todo_lists/#{todo_list.id}" }
      it_behaves_like 'authentication error'
    end

    context 'when user is authenticated' do
      it 'returns the todo list details' do
        get "/todo_lists/#{todo_list.id}", headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(todo_list.id)
      end
    end

    context 'when collaborator tries to access' do
      it 'returns the todo list details' do
        get "/todo_lists/#{todo_list.id}", headers: collaboration_user_headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['id']).to eq(todo_list.id)
      end
    end

    context 'when user tries to access another user todo list' do
        subject{ get "/todo_lists/#{other_todo_list.id}", headers: headers }
        it_behaves_like 'not_found error'
    end

    context 'when non-collaborator tries to access' do
        subject{ get "/todo_lists/#{todo_list.id}", headers: other_user_headers }
        it_behaves_like 'not_found error'
    end
  end

  describe 'POST /todo_lists' do
    let(:valid_params) { { todo_list: attributes_for(:todo_list) } }
    let(:invalid_params) { { todo_list: { name: '' } } }

    context 'when user is not authenticated' do
      subject{ post '/todo_lists', params: valid_params }
      it_behaves_like 'authentication error'
    end

    context 'when user is authenticated' do
      subject{ expect do
        post '/todo_lists', params: valid_params, headers: headers
      end.to change(user.todo_lists, :count).by(1) }
      it_behaves_like 'successful creation'
    
      subject{ post '/todo_lists', params: invalid_params, headers: headers }
      it_behaves_like 'unprocessable_entity error', "Name can't be blank"
    end

    context 'when user is a collaborator' do
      subject{ expect do
        post '/todo_lists', params: valid_params, headers: collaboration_user_headers
      end.to change(collaboration_user.todo_lists, :count).by(1) }

      it_behaves_like 'successful creation'
    end

    context 'when user is not a collaborator' do
      subject{ expect do
        post '/todo_lists', params: valid_params, headers: other_user_headers
      end.to change(other_user.todo_lists, :count).by(1)}
      it_behaves_like 'successful creation'
    end
  end

  describe 'PATCH /todo_lists/:id' do
    let(:update_params) { { todo_list: { name: 'Updated Name' } } }

    context 'when user is not authenticated' do
      subject{ patch "/todo_lists/#{todo_list.id}", params: update_params }
      it_behaves_like 'authentication error'
    end

    context 'when user updates their own todo list' do
      it 'updates the todo list' do
        patch "/todo_lists/#{todo_list.id}", params: update_params, headers: headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['todo_list']['name']).to eq(update_params[:todo_list][:name])
      end
    end

    context 'when user tries to update another user todo list' do 
      subject{ patch "/todo_lists/#{other_todo_list.id}", params: update_params, headers: headers }
      it_behaves_like 'not_found error' 
    end

    context 'when collaborator tries to update' do
      it 'updates the todo list' do
        patch "/todo_lists/#{todo_list.id}", params: update_params, headers: collaboration_user_headers
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['todo_list']['name']).to eq(update_params[:todo_list][:name])
      end
    end

    context 'when  not collaborator tries to update' do 
      subject{ patch "/todo_lists/#{todo_list.id}", params: update_params, headers: other_user_headers }
      it_behaves_like 'not_found error'
    end
  end

  describe 'DELETE /todo_lists/:id' do
    context 'when user is not authenticated' do
      subject{ delete "/todo_lists/#{other_todo_list.id}" }
      it_behaves_like 'authentication error'
    end

    context 'when non-collaborator tries to delete todo_list' do
      subject{ delete "/todo_lists/#{other_todo_list.id}", headers: headers }
      it_behaves_like 'not_found error' 
    end

    context 'when collaborator tries to delete todo_list' do
      subject{delete "/todo_lists/#{todo_list.id}", headers: collaboration_user_headers}
      it_behaves_like 'authorization error'    
    end

    context 'when user tries to delete todo_list' do
      it 'deletes the todo list' do
        expect do
          delete "/todo_lists/#{todo_list.id}", headers: headers
        end.to change(TodoList, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
