class Api::V1::UsersController < ApplicationController

  def index
    users = User.all
    # as_json => ハッシュの形でSONデータを返す { "id" => 1, "name" => "test", ... }
    render json: users.as_json(only: [:id, :name, :email, :created_at])
  end
end
