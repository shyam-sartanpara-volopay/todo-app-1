require 'rails_helper'

RSpec.describe "Collaborations API", type: :request do
  let!(:user) { create(:user) }
  let!(:collaborator) { create(:user) }
  let!(:todo_list) { create(:todo_list, user: user) }
  let!(:collaboration) { create(:collaboration, user: collaborator, todo_list: todo_list) }
  let(:valid_attributes) { { user_id: collaborator.id } }
  let(:invalid_attributes) { { user_id: nil } }
  let(:auth_headers) { user.create_new_auth_token }

  describe "GET #index" do
    context "when authenticated" do
      it "returns all collaborations for a todo list" do
        get todo_list_collaborations_path(todo_list), headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to be_an(Array)
        expect(json_response['message']).to eq('Collaborations retrieved successfully')

        first_collaboration = json_response['data'].first
        expect(first_collaboration['id']).to eq(collaboration.id)
        expect(first_collaboration['user_id']).to eq(collaborator.id)
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        get todo_list_collaborations_path(todo_list), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET #show" do
    context "when authenticated" do
      it "returns the requested collaboration" do
        get todo_list_collaboration_path(todo_list, collaboration), headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']['id']).to eq(collaboration.id)
        expect(json_response['message']).to eq('Collaboration retrieved successfully')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        get todo_list_collaboration_path(todo_list, collaboration), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST #create" do
    context "when authenticated" do
      it "creates a new collaboration" do
        new_user = create(:user)

        expect {
          post todo_list_collaborations_path(todo_list), params: { collaboration: { user_id: new_user.id } }, headers: auth_headers, as: :json
        }.to change(Collaboration, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Collaboration added successfully')
        expect(json_response['data']['user_id']).to eq(new_user.id)
      end
    end

    context "when user tries to collaborate with themselves" do
      it "returns an error" do
        post todo_list_collaborations_path(todo_list), params: { collaboration: { user_id: user.id } }, headers: auth_headers, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)

        expect(json_response['errors']).to include('User cannot be a collaborator on their own todo list')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        post todo_list_collaborations_path(todo_list), params: { collaboration: valid_attributes }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH #update" do
    context "when authenticated" do
      it "updates the collaboration" do
        new_collaborator = create(:user)

        patch todo_list_collaboration_path(todo_list, collaboration), params: { collaboration: { user_id: new_collaborator.id } }, headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Collaboration updated successfully')
        expect(json_response['data']['user_id']).to eq(new_collaborator.id)
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        patch todo_list_collaboration_path(todo_list, collaboration), params: { collaboration: valid_attributes }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when authenticated" do
      it "deletes the collaboration" do
        expect {
          delete todo_list_collaboration_path(todo_list, collaboration), headers: auth_headers, as: :json
        }.to change(Collaboration, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Collaboration removed successfully')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        delete todo_list_collaboration_path(todo_list, collaboration), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
