require 'rails_helper'

RSpec.describe 'Collaborations', type: :request do
  let!(:user) { create(:user) }
  let!(:collaboration_user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:user_headers) { user.create_new_auth_token }
  let(:collaboration_user_headers) { collaboration_user.create_new_auth_token }
  let(:todo_list) { create(:todo_list, user: user) }
  let!(:collaboration) { create(:collaboration, user: collaboration_user, todo_list: todo_list) }

  describe 'GET /todo_lists/:todo_list_id/collaborations' do
    context 'when user is the owner' do
      it 'returns list of collaborations' do
        get "/todo_lists/#{todo_list.id}/collaborations", headers: user_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not owner' do
      it 'returns authorization error' do
        get "/todo_lists/#{todo_list.id}/collaborations", headers: collaboration_user_headers
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq('error' => 'You are not authorized to perform this action')
      end
    end
  end

  describe 'POST /todo_lists/:todo_list_id/collaborations' do
    context 'when user is owner' do
      it 'creates collaboration' do
        post "/todo_lists/#{todo_list.id}/collaborations", params: { user_id: other_user.id }, headers: user_headers
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Collaboration created successfully')
      end
    end

    context 'when user added as collaboration' do
      it 'returns error' do
        post "/todo_lists/#{todo_list.id}/collaborations", params: { user_id: user.id }, headers: user_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq('error' => 'Owner cannot be a collaborator')
      end
    end

    context 'when user adds a existing collaboration' do
      it 'returns error' do
        post "/todo_lists/#{todo_list.id}/collaborations", params: { user_id: collaboration_user.id },
                                                           headers: user_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq('error' => 'User is already a collaborator')
      end
    end

    context 'when user is not owner' do
      it 'returns authorization error' do
        post "/todo_lists/#{todo_list.id}/collaborations", params: { user_id: other_user.id },
                                                           headers: collaboration_user_headers
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq('error' => 'You are not authorized to perform this action')
      end
    end
  end

  describe 'DELETE /todo_lists/:todo_list_id/collaborations/:user_id' do
    context 'User tries to delete an existing collaboration' do
      it 'deleted  successfully' do
        delete "/todo_lists/#{todo_list.id}/collaborations/#{collaboration_user.id}", headers: user_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'User tries to delete an not existing collaboration' do
      it 'returns error' do
        delete "/todo_lists/#{todo_list.id}/collaborations/#{other_user.id}", headers: user_headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq('error' => 'Collaboration not found')
      end
    end

    context 'when user is not owner' do
      it 'returns authorization error' do
        delete "/todo_lists/#{todo_list.id}/collaborations/#{user.id}", headers: collaboration_user_headers
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)).to eq('error' => 'You are not authorized to perform this action')
      end
    end
  end
end
