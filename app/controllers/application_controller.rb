class ApplicationController < ActionController::Base
	include Pundit
	protect_from_forgery with: :exception

	before_filter :configure_permitted_parameters, if: :devise_controller? 
	protect_from_forgery with: :exception

	protected

	# このメソッドを定義
	def configure_permitted_parameters
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:name, :email, :password, :password_confirmation, :role, :remember_me) }
		devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:name, :email, :password, :remember_me) }
		devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password) }
	end


	def after_sign_in_path_for(resource)
		tasks_path
	end

	def after_sign_up_path_for(resource)
		tasks_path
	end

	def after_sign_out_path_for(resource)
		tasks_path
	end

end
