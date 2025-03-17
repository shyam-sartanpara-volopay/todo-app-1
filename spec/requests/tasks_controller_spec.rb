require 'rails_helper'

RSpec.describe "Tasks API", type: :request do
  let!(:user) { create(:user) }
  let!(:todo_list) { create(:todo_list, user: user) } 
  let!(:task) { create(:task, todo_list: todo_list) }
  let(:valid_attributes) { { title: "New Task", description: "RSpec testing", completed: false } }
  let(:invalid_attributes) { { title: "", description: "", completed: nil } }
  let(:auth_headers) { user.create_new_auth_token }

  describe "GET #index" do
    context "when authenticated" do
      it "returns all tasks for a todo list" do
        get todo_list_tasks_path(todo_list), headers: auth_headers, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']).to be_an(Array)
        expect(json_response['message']).to eq('Tasks retrieved successfully')

        first_task = json_response['data'].first
        expect(first_task['id']).to eq(task.id)
        expect(first_task['title']).to eq(task.title)
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        get todo_list_tasks_path(todo_list), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET #show" do
    context "when authenticated" do
      it "returns the requested task" do
        get todo_list_task_path(todo_list, task), headers: auth_headers, as: :json  # Fix: Nested path

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['data']['id']).to eq(task.id)
        expect(json_response['message']).to eq('Task retrieved successfully')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        get todo_list_task_path(todo_list, task), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST #create" do
    context "when authenticated" do
      it "creates a new task" do
        expect {
          post todo_list_tasks_path(todo_list), params: { task: valid_attributes }, headers: auth_headers, as: :json  # Fix: Nested path
        }.to change(Task, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Task created successfully')
        expect(json_response['data']['title']).to eq(valid_attributes[:title])
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        post todo_list_tasks_path(todo_list), params: { task: valid_attributes }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH #update" do
    context "when authenticated" do
      it "updates the task" do
        patch todo_list_task_path(todo_list, task), params: { task: { title: "Updated Task" } }, headers: auth_headers, as: :json  # Fix: Nested path

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Task updated successfully')
        expect(json_response['data']['title']).to eq('Updated Task')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        patch todo_list_task_path(todo_list, task), params: { task: { title: "Updated Task" } }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when authenticated" do
      it "deletes the task" do
        expect {
          delete todo_list_task_path(todo_list, task), headers: auth_headers, as: :json  # Fix: Nested path
        }.to change(Task, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Task deleted successfully')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        delete todo_list_task_path(todo_list, task), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
