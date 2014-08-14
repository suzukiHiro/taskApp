class Task < ActiveRecord::Base
	belongs_to :user, :foreign_key => "created_user_id"

	STATUS_OPTIONS = ["TODO", "DOING", "DONE"].freeze
end
