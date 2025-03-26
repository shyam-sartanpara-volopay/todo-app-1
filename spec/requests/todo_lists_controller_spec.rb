require 'rails_helper'

RSpec.describe "TodoLists API", type: :request do
  let!(:owner) { create(:user) }
  let!(:collaborator) { create(:user) }
  let!(:random_user) { create(:user) } # A user who is neither an owner nor a collaborator

  let!(:owner_todo_list) { create(:todo_list, user: owner) }
  let!(:collaborator_todo_list) { create(:todo_list, user: collaborator) }
  let!(:owner_task) { create(:task, todo_list: owner_todo_list) }

  let!(:collaboration) { create(:collaboration, user: collaborator, todo_list: owner_todo_list) }

  let(:owner_headers) { owner.create_new_auth_token }
  let(:collaborator_headers) { collaborator.create_new_auth_token }
  let(:random_user_headers) { random_user.create_new_auth_token }

  let(:valid_attributes) { { category: "Work" } }
  let(:invalid_attributes) { { category: "" } }

  describe "Owner permissions" do
    describe "GET #index" do
      it "returns all todo lists owned or collaborated on by the user" do
        get todo_lists_path, headers: owner_headers, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        
        list_ids = json_response['data'].map { |list| list['id'] }
        expect(list_ids).to include(owner_todo_list.id)
      end
    end

    describe "GET #show" do
      it "returns the requested todo list with tasks" do
        get todo_list_path(owner_todo_list), headers: owner_headers, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']['id']).to eq(owner_todo_list.id)
        expect(json_response['data']['tasks']).to be_an(Array)
        expect(json_response['data']['tasks'].first['id']).to eq(owner_task.id)
      end
    end

    describe "POST #create" do
      it "creates a new todo list" do
        expect {
          post todo_lists_path, 
               params: { todo_list: valid_attributes }, 
               headers: owner_headers, 
               as: :json
        }.to change(TodoList, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(TodoList.last.user_id).to eq(owner.id)
      end
    end

    describe "PATCH #update" do
      it "updates own todo list" do
        patch todo_list_path(owner_todo_list), 
              params: { todo_list: { category: "Updated Category" } }, 
              headers: owner_headers, 
              as: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data']['category']).to eq('Updated Category')
      end
    end

    describe "DELETE #destroy" do
      it "deletes own todo list" do
        expect {
          delete todo_list_path(owner_todo_list), 
                 headers: owner_headers, 
                 as: :json
        }.to change(TodoList, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "Collaborator permissions" do
    describe "GET #show" do
      it "allows access to a todo list they collaborate on" do
        get todo_list_path(owner_todo_list), headers: collaborator_headers, as: :json
        
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['data']['id']).to eq(owner_todo_list.id)
      end
    end

    describe "PATCH #update" do
      it "does not allow updating a todo list they only collaborate on" do
        patch todo_list_path(owner_todo_list), 
              params: { todo_list: { category: "Updated" } }, 
              headers: collaborator_headers, 
              as: :json

        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "DELETE #destroy" do
      it "does not allow deleting a todo list they only collaborate on" do
        expect {
          delete todo_list_path(owner_todo_list), headers: collaborator_headers, as: :json
        }.not_to change(TodoList, :count)

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "Random user (unauthorized) access" do
    it "does not allow viewing a todo list they are not part of" do
      get todo_list_path(owner_todo_list), headers: random_user_headers, as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "does not allow updating a todo list they are not part of" do
      patch todo_list_path(owner_todo_list), 
            params: { todo_list: { category: "Updated" } }, 
            headers: random_user_headers, 
            as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it "does not allow deleting a todo list they are not part of" do
      delete todo_list_path(owner_todo_list), headers: random_user_headers, as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "Unauthenticated access" do
    it "returns unauthorized for index" do
      get todo_lists_path, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
    
    it "returns unauthorized for show" do
      get todo_list_path(owner_todo_list), as: :json
      expect(response).to have_http_status(:unauthorized)
    end
    
    it "returns unauthorized for create" do
      post todo_lists_path, params: { todo_list: valid_attributes }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
    
    it "returns unauthorized for update" do
      patch todo_list_path(owner_todo_list), 
            params: { todo_list: { category: "Updated" } }, 
            as: :json
      expect(response).to have_http_status(:unauthorized)
    end
    
    it "returns unauthorized for destroy" do
      delete todo_list_path(owner_todo_list), as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
