require 'rails_helper'

RSpec.describe 'Collaborations', type: :request do
  let!(:user) { create(:user) }
  let!(:collaboration_user) { create(:user) }
  let!(:other_user) { create(:user) }
  let(:other_user_headers) { other_user.create_new_auth_token }
  let(:user_headers) { user.create_new_auth_token }
  let(:collaboration_user_headers) { collaboration_user.create_new_auth_token }
  let(:todo_list) { create(:todo_list, user: user) }
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

  RSpec.shared_examples 'unprocessable_entity error' do |error_message|
    it 'returns unprocessable_entity error' do
      subject
      expect(response).to have_http_status(:unprocessable_entity) 
      expect(JSON.parse(response.body)['errors'].first).to include(error_message)
    end
  end

  RSpec.shared_examples 'not_found error' do |error_message|
    it 'returns not_found error' do
      subject
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq(error_message)
    end
  end

  describe 'GET /todo_lists/:todo_list_id/collaborations' do
    context 'when user is the owner but not authenticated' do
      subject{ get "/todo_lists/#{todo_list.id}/collaborations" }
      it_behaves_like 'authentication error' 
    end

    context 'when user is the owner' do
      it 'returns list of collaborations' do
        get "/todo_lists/#{todo_list.id}/collaborations", headers: user_headers
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body.pluck('user_id')).to eq([collaboration_user.id])
      end
    end

    context 'when user is not owner but a collaborator' do
      it 'returns list of collaborations' do
        get "/todo_lists/#{todo_list.id}/collaborations", headers: collaboration_user_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not a collaborator' do
      subject{ get "/todo_lists/#{todo_list.id}/collaborations", headers: other_user_headers}
      it_behaves_like 'not_found error', 'No TodoList exists'
    end
  end

  describe 'POST /todo_lists/:todo_list_id/collaborations' do
    context 'when user is not authenticated' do
      subject{ post "/todo_lists/#{todo_list.id}/collaborations", params: { email: other_user.email } }
      it_behaves_like 'authentication error' 
    end

    context 'when user is owner' do
      it 'creates collaboration' do
        post "/todo_lists/#{todo_list.id}/collaborations", params: { email: other_user.email }, headers: user_headers
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Collaboration created successfully')
      end
    end

    context 'when user added as collaboration' do
      subject{ post "/todo_lists/#{todo_list.id}/collaborations", params: { email: user.email }, headers: user_headers }
      it_behaves_like 'unprocessable_entity error', 'Owner cannot be a collaborator'
    end

    context 'when user adds a existing collaboration' do
      subject{ post "/todo_lists/#{todo_list.id}/collaborations", params: { email: collaboration_user.email },
                                                          headers: user_headers}
      it_behaves_like 'unprocessable_entity error', 'User is already a collaborator'                                              
    
    end

    context 'when user is not owner' do
      subject{ post "/todo_lists/#{todo_list.id}/collaborations", params: { email: other_user.email },
                                                          headers: collaboration_user_headers }
      it_behaves_like 'authorization error'                                     
    end
  end

  describe 'DELETE /todo_lists/:todo_list_id/collaborations/:user_id' do
    context 'when user is not authenticated' do
      subject{ delete "/todo_lists/#{todo_list.id}/collaborations/#{collaboration_user.id}" }
      it_behaves_like 'authentication error' 
    end

    context 'User tries to delete an existing collaboration' do
      it 'deleted  successfully' do
        delete "/todo_lists/#{todo_list.id}/collaborations/#{collaboration_user.id}", headers: user_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'User tries to delete an not existing collaboration' do
      subject{ delete "/todo_lists/#{todo_list.id}/collaborations/#{other_user.id}", headers: user_headers }
      it_behaves_like 'not_found error', 'Collaboration not found'
    end

    context 'when user is not owner' do
        subject{ delete "/todo_lists/#{todo_list.id}/collaborations/#{collaboration_user.id}", headers: collaboration_user_headers}
        it_behaves_like 'authorization error' 
    end
  end
end
