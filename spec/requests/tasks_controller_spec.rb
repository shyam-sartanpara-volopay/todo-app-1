require 'rails_helper'

RSpec.describe TasksController, type: :request do
  let!(:user) { create(:user) } # Create a test user
  let!(:task) { create(:task, user: user) } # Ensure the task belongs to the user
  let(:valid_attributes) { { title: "New Task", description: "RSpec testing", completed: false } }
  let(:invalid_attributes) { { title: "", description: "", completed: nil } }
  let(:auth_headers) { user.create_new_auth_token } # Generate authentication headers

  describe "GET #index" do
    context "when authenticated" do
      it "returns all tasks" do
        get tasks_path, headers: auth_headers, as: :json
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['tasks']).to be_an(Array)
        expect(json_response['message']).to eq('Tasks retrieved successfully')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        get tasks_path, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST #create" do
    context "when authenticated" do
      it "creates a new task" do
        expect {
          post tasks_path, params: { task: valid_attributes }, headers: auth_headers, as: :json
        }.to change(Task, :count).by(1)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task created successfully')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        post tasks_path, params: { task: valid_attributes }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH #update" do
    context "when authenticated" do
      it "updates the task" do
        patch task_path(task), params: { task: { title: "Updated Task" } }, headers: auth_headers, as: :json
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task updated successfully')
        expect(json_response['task']['title']).to eq('Updated Task')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        patch task_path(task), params: { task: { title: "Updated Task" } }, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when authenticated" do
      it "deletes the task" do
        expect {
          delete task_path(task), headers: auth_headers, as: :json
        }.to change(Task, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task deleted successfully')
      end
    end

    context "when not authenticated" do
      it "returns unauthorized status" do
        delete task_path(task), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
