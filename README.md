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
ブログの所有者のみ閲覧可能にしてみると、こんな感じです。

```
# app/policies/task_policy.rb

class TaskPolicy < Struct.new(:user, :post)
  def owned
    bost.user_id == user.id
  end

  def show?
    owned
  end
end
```

以上。またの。
