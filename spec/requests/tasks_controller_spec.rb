require 'rails_helper'

RSpec.describe TasksController, type: :request do
  let!(:task) { create(:task) } # Create a test task before each test
  let(:valid_attributes) { { title: "New Task", description: "RSpec testing", completed: false } }
  let(:invalid_attributes) { { title: "", description: "", completed: nil } }

  describe "GET #index" do
    context "when tasks exist" do
      it "returns all tasks" do
        get tasks_path, as: :json
        expect(response).to have_http_status(:ok)
        
        json_response = JSON.parse(response.body)
        expect(json_response['tasks']).to be_an(Array)
        expect(json_response['message']).to eq('Tasks retrieved successfully')
      end
    end

    context "when no tasks exist" do
      before { Task.destroy_all } # Clear all tasks
      it "returns an empty array" do
        get tasks_path, as: :json
        json_response = JSON.parse(response.body)

        expect(json_response['tasks']).to eq([])
        expect(json_response['message']).to eq('Tasks retrieved successfully')
      end
    end
  end

  describe "GET #show" do
    context "when task exists" do
      it "returns the task" do
        get task_path(task), as: :json
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['task']['id']).to eq(task.id)
        expect(json_response['message']).to eq('Task retrieved successfully')
      end
    end

    context "when task does not exist" do
      it "returns a not found message" do
        get task_path(9999), as: :json
        expect(response).to have_http_status(:not_found)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task not found')
      end
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new task" do
        expect {
          post tasks_path, params: { task: valid_attributes }, as: :json
        }.to change(Task, :count).by(1)
        
        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task created successfully')
      end
    end

    context "with invalid attributes" do
      it "returns errors" do
        post tasks_path, params: { task: invalid_attributes }, as: :json
        puts response.body  # Debugging log

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task creation failed')
        expect(json_response['errors']).not_to be_empty
      end
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "updates the task" do
        patch task_path(task), params: { task: { title: "Updated Task" } }, as: :json
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task updated successfully')
        expect(json_response['task']['title']).to eq('Updated Task')
      end
    end

    context "with invalid attributes" do
      it "returns errors" do
        patch task_path(task), params: { task: { title: "" } }, as: :json
        puts response.body  # Debugging log

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task update failed')
        expect(json_response['errors']).not_to be_empty
      end
    end
  end

  describe "DELETE #destroy" do
    context "when task exists" do
      it "deletes the task" do
        expect {
          delete task_path(task), as: :json
        }.to change(Task, :count).by(-1)

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task deleted successfully')
      end
    end

    context "when task does not exist" do
      it "returns an error message" do
        delete task_path(9999), as: :json
        expect(response).to have_http_status(:not_found)

        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Task not found')
      end
    end
  end
end
