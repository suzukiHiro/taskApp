class TaskPolicy < Struct.new(:user, :task)
	def owned
		if task.created_user_id === user.id then
			return true
		else
			return false
		end
	end

	def index?
		false
	end

	def show?
		true
	end

	def create?
		new?
	end

	def new?
		true
	end

	def update?
		edit?
	end

	def edit?
		task.created_user_id === user.id
	end

	def destroy?
		owned
	end
end