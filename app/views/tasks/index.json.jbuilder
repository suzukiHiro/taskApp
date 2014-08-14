json.array!(@tasks) do |task|
  json.extract! task, :id, :title, :description, :due_date, :status, :created_user_id, :assigned_user_id
  json.url task_url(task, format: :json)
end
