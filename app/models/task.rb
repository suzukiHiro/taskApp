class Task < ActiveRecord::Base
	belongs_to :created_user, :class_name => 'User', :foreign_key => 'created_user_id'
	belongs_to :assigned_user, :class_name => 'User', :foreign_key => 'assigned_user_id'

	STATUS_OPTIONS = ["TODO", "DOING", "DONE"].freeze

end
