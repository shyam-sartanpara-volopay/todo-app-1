require 'rails_helper'

RSpec.describe "TodoLists API", type: :request do
  let!(:user) { create(:user) }
  let!(:todo_list) { create(:todo_list, user: user) }
  let!(:task) { create(:task, todo_list: todo_list) }
  let(:valid_attributes) { { category: "Work" } }
  let(:invalid_attributes) { { category: "" } }
  let(:auth_headers) { user.create_new_auth_token }

  describe "GET #index" do
    context "when authenticated" do
      it "returns all todo lists with tasks" do
        get todo_lists_path, headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to be_an(Array)
        expect(json_response['message']).to eq('Todo lists retrieved successfully')

        first_todo_list = json_response['data'].first
        expect(first_todo_list['id']).to eq(todo_list.id)
        expect(first_todo_list['tasks']).to be_an(Array)
        expect(first_todo_list['tasks'].first['id']).to eq(task.id)
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        get todo_lists_path, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET #show" do
    context "when authenticated" do
      it "returns the requested todo list with tasks" do
        get todo_list_path(todo_list), headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']['id']).to eq(todo_list.id)
        expect(json_response['message']).to eq('Todo list retrieved successfully')

        # Validate tasks are included
        expect(json_response['data']['tasks']).to be_an(Array)
        expect(json_response['data']['tasks'].first['id']).to eq(task.id)
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        get todo_list_path(todo_list), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST #create" do
    context "when authenticated" do
      it "creates a new todo list" do
        expect {
          post todo_lists_path, params: { todo_list: valid_attributes }, headers: auth_headers, as: :json
        }.to change(TodoList, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Todo list created successfully')
        expect(json_response['data']['category']).to eq(valid_attributes[:category])
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        post todo_lists_path, params: { todo_list: valid_attributes }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH #update" do
    context "when authenticated" do
      it "updates the todo list" do
        patch todo_list_path(todo_list), params: { todo_list: { category: "Updated Category" } }, headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Todo list updated successfully')
        expect(json_response['data']['category']).to eq('Updated Category')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        patch todo_list_path(todo_list), params: { todo_list: { category: "Updated Category" } }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when authenticated" do
      it "deletes the todo list" do
        expect {
          delete todo_list_path(todo_list), headers: auth_headers, as: :json
        }.to change(TodoList, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Todo list deleted successfully')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        delete todo_list_path(todo_list), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
