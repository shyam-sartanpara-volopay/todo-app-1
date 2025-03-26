require 'rails_helper'

RSpec.describe "Tasks API", type: :request do
  let!(:owner) { create(:user) }
  let!(:collaborator) { create(:user) }
  let!(:random_user) { create(:user) }

  let!(:todo_list) { create(:todo_list, user: owner) }
  let!(:task) { create(:task, todo_list: todo_list) }
  let!(:collaboration) { create(:collaboration, user: collaborator, todo_list: todo_list) }

  let(:owner_headers) { owner.create_new_auth_token }
  let(:collaborator_headers) { collaborator.create_new_auth_token }
  let(:random_user_headers) { random_user.create_new_auth_token }

  let(:valid_attributes) { { title: "New Task", description: "RSpec testing", completed: false } }
  let(:invalid_attributes) { { title: "", description: "", completed: nil } }

  describe "GET #index" do
    it "returns all tasks for the owner" do
      get todo_list_tasks_path(todo_list), headers: owner_headers, as: :json
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
        
      task_ids = json_response['data'].map { |t| t['id'] }
      expect(task_ids).to include(task.id)
    end

    it "returns all tasks for a collaborator" do
      get todo_list_tasks_path(todo_list), headers: collaborator_headers, as: :json
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
        
      task_ids = json_response['data'].map { |t| t['id'] }
      expect(task_ids).to include(task.id)
    end
  end

  describe "GET #show" do
    it "allows the owner to view a task" do
      get todo_list_task_path(todo_list, task), headers: owner_headers, as: :json
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response['data']['id']).to eq(task.id)
    end

    it "allows a collaborator to view a task" do
      get todo_list_task_path(todo_list, task), headers: collaborator_headers, as: :json
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)

      expect(json_response['data']['id']).to eq(task.id)
    end
  end

  describe "POST #create" do
    it "allows the owner to create a task" do
      expect {
        post todo_list_tasks_path(todo_list), params: { task: valid_attributes }, headers: owner_headers, as: :json
      }.to change(Task, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).not_to be_nil
    end

    it "allows a collaborator to create a task" do
      expect {
        post todo_list_tasks_path(todo_list), params: { task: valid_attributes }, headers: collaborator_headers, as: :json
      }.to change(Task, :count).by(1)

      expect(response).to have_http_status(:created)
      json_response = JSON.parse(response.body)
      expect(json_response['data']['id']).not_to be_nil
    end
  end

  describe "PATCH #update" do
    it "allows the owner to update a task" do
      patch todo_list_task_path(todo_list, task), params: { task: { title: "Updated Task" } }, headers: owner_headers, as: :json
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      
      expect(json_response['message']).to eq('Task updated successfully')
      expect(json_response['data']['title']).to eq('Updated Task')
    end

    it "allows a collaborator to update a task" do
      patch todo_list_task_path(todo_list, task), params: { task: { title: "Updated Task" } }, headers: collaborator_headers, as: :json
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      
      expect(json_response['message']).to eq('Task updated successfully')
      expect(json_response['data']['title']).to eq('Updated Task')
    end
  end

  describe "DELETE #destroy" do
    it "allows the owner to delete a task" do
      expect {
        delete todo_list_task_path(todo_list, task), headers: owner_headers, as: :json
      }.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it "does not allow a collaborator to delete a task" do
      delete todo_list_task_path(todo_list, task), headers: collaborator_headers, as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end


  describe "Random user (unauthorized) access" do
    it "does not allow viewing a task they are not part of" do
      get todo_list_task_path(todo_list, task), headers: random_user_headers, as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "does not allow updating a task they are not part of" do
      patch todo_list_task_path(todo_list, task), 
            params: { todo_list: { category: "Updated" } }, 
            headers: random_user_headers, 
            as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it "does not allow deleting a todo list they are not part of" do
      delete todo_list_task_path(todo_list, task), headers: random_user_headers, as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end


  describe "Unauthenticated access" do
    it "returns unauthorized for index" do
      get todo_list_tasks_path(todo_list), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for show" do
      get todo_list_task_path(todo_list, task), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for create" do
      post todo_list_tasks_path(todo_list), params: { task: valid_attributes }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for update" do
      patch todo_list_task_path(todo_list, task), params: { task: { title: "Updated Task" } }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns unauthorized for delete" do
      delete todo_list_task_path(todo_list, task), as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
