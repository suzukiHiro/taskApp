class User < ActiveRecord::Base
	has_many :tasks, :foreign_key => "created_user_id"
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
			 :recoverable, :rememberable, :trackable, :validatable

	STATUS_OPTIONS = ["gen", "admin"].freeze
end
