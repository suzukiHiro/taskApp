class User < ActiveRecord::Base
	has_many :tasks, :foreign_key => "created_user_id"
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
			 :recoverable, :rememberable, :trackable, :validatable
	attr_accessor :login


	validates :name, presence: true  

	def self.find_first_by_auth_conditions(warden_conditions)
		conditions = warden_conditions.dup
		if login = conditions.delete(:login)
			where(conditions).where(["lower(name) = :value OR lower(email) = :value", { :value => login.downcase }]).first
		else
			where(conditions).first
		end
	end

	ROLE_OPTIONS = ["gen", "admin"].freeze
end
