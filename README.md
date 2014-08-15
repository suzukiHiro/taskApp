# Punditの使い方

## 準備
Gemfileに追加

```
gem 'pundit'
```

インストール

```
$ bundle install
```

policyクラスを作成

```
$ rails generate pundit:install
	create  app/policies/application_policy.rb
```

## 実装
taskのCRUDに対して、制限をかけていきます。
まずは、PunditをIncludeします。

```
class ApplicationController < ActionController::Base
	include Pundit
```

task_policyクラスを作成。

```
rails generate pundit:policy task
  create  app/policies/task_policy.rb
```

そして、制限をかけたいアクションに対して、Pundit#authorize関数にオブジェクトとクエリ（省略可）をわたします。

```
# app/controllers/tasks_controller.rb

def show
	authorize @task
end
```

ちなみに、authorize関数を覗いてみると、こんな感じになっています。

```
# lib/pundit.rb
def authorize(record, query=nil)
	query ||= params[:action].to_s + "?"
	@_policy_authorized = true

	policy = policy(record)
	unless policy.public_send(query)
		error = NotAuthorizedError.new("not allowed to #{query} this #{record}")
		error.query, error.record, error.policy = query, record, policy

		raise error
	end

	true
end
```

アクセスしているアクションに対して制限をかけるか、クエリを指定して制限をかけるかになっています。

アクション名＋'?'のPolicyメソッドが呼ばれるので、ここで制限をかけます。
タスクの作成者のみ閲覧可能にしてみると、こんな感じです。

```
# app/policies/task_policy.rb

class TaskPolicy < Struct.new(:user, :task)
  def owned
    task.created_user_id == user.id
  end

  def show?
    owned
  end
end
```

権限エラーの際に、リダイレクト設定。

```
# app/controllers/tasks_controllers.rb

rescue_from Pundit::NotAuthorizedError, :with => :record_not_found

def record_not_found
	redirect_to tasks_url, :alert => "Couldn't find task"
end
```


# deviseの実装

## setup

Gemfile に devise を追加します。

```
$ vim Gemfile
$ gem 'devise'
```

bundle install を実行。

```
$ bundle install
```
 
ジェネレータを実行して、devise をインストール。

```
$ bundle exec rails generate devise:install
```

続いて devise ジェネレータで、アプリケーションのユーザーのモデルを任意の名前で作成します。

```
$ bundle exec rails generate devise User
```

マイグレート実行。

``` 
$ bundle exec rake db:migrate
```

## devise のヘルパーメソッド

認証を必要とするコントローラーの before_action で以下のように指定。ユーザーのモデル名が User の場合は以下。これで、ログイン中のユーザーのみに許可できるコントローラー・アクションを指定できます。

```
before_action :authenticate_user!
```

ユーザーがサインインしているかどうかを検証するメソッド。

```
user_signed_in?
```

現在サインインしているユーザーを取得。

```
current_user
```

ユーザーのセッション情報にアクセス。

```
user_session
```

ユーザーのモデル名が Member であれば、以上のヘルパーメソッドはそれぞれ以下となります。

```
before_action :authenticate_member!
member_signed_in?
current_member
member_session
```

# deviseで登録フォームの項目を追加する

### devise のジェネレータでビューをコピー生成

まず、Devise の gem で管理されているデフォルトのビューを、app/views/users 内にコピー生成する。

```sh
$ bundle exec rails generate devise:views users

railsapp/
| app
| | views/
| | | users/
| | | | confirmations/
| | | | mailer/
| | | | passwords/
| | | | registrations/
| | | | sessions/
| | | | shared/
| | | | unlocks/
```

中身は以上のような感じ。Devise で管理されるビューをカスタマイズする場合は、この app/views/users を編集します。

### 個別のビューをカスタマイズする場合

```ruby
# config/initializers/devise.rb

config.scoped_views = true
```

## ユーザー登録フォームのビューに name 用の入力フィールドを追加

``` ruby
# app/views/users/regsitrations/new.html.erb

<h2>Sign up</h2>
 
<%= form_for(resource, :as => resource_name, :url => registration_path(resource_name)) do |f| %>
  <%= devise_error_messages! %>
 
  <div><%= f.label :email %><br />
  <%= f.email_field :email, :autofocus => true %></div>
 
  <div><%= f.label :name %><br />
  <%= f.text_field :name %></div>
 
  <div><%= f.label :password %><br />
  <%= f.password_field :password %></div>
 
  <div><%= f.label :password_confirmation %><br />
  <%= f.password_field :password_confirmation %></div>
 
  <div><%= f.submit "Sign up" %></div>
<% end %>
 
<%= render "users/shared/links" %>
```

### name フィールドを許可する strong parameters の設定

``` ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base

  before_filter :configure_permitted_parameters, if: :devise_controller?
  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << :name
    end
end
```

### User モデルでの validation

``` ruby
# app/models/user.rb

validates :name, presence: true, length: { maximum: 50 }

```

以上で、サインアップ用のユーザー登録フォームに name という入力フィールドを追加できました。必要に応じて、edit ビューなども編集。


以上。またの。