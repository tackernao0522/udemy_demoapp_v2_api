require "validator/email_validator"

class User < ApplicationRecord
  # Token生成モジュール
  include TokenGenerateService

  # Userクラスの一番上に追加
  # バリデーション直前
  before_validation :downcase_email

  # gem bcrypt
  # 1. passwordを暗号化する
  # 2. password_digest => password
  # 3. password_confirmation => パスワードの一致確認
  # 4. 一致のバリデーション追加
  # 5. authenticate()
  # 6. 最大文字数 72文字まで
  # 7. User.create() => 入力必須バリデーション、User.update() => x
  has_secure_password # 新規登録時はpassoword入力必須になる

  # validates
  # User.create(name: "                                        ")
  # 名前を入力してください。文字数は30文字まで(空白の場合には出ないようにする allow_blank: true)
  validates :name, presence: true,      # 入力必須
                    length: {
                      maximum: 30,      # 最大文字数
                      allow_blank: true # Null(nil), 空白文字の場合スキップ(空白文字の場合には無駄な検証を行わない)
                    }
  validates :email, presence: true,
                    email: { allow_blank: true }

  VALID_PASSWORD_REGEX = /\A[\w\-]+\z/ # 先頭から末尾まで、全て「a-zA-Z0-9_」と「-」にマッチする文字列を許容する。
  # \A     => 文字列の先頭にマッチ
  # [\w\-] => a-zA-X0-9_-
  # +      => 1文字以上繰り返す
  # \z     => 文字列の末尾にマッチ
  validates :password, presence: true, # nameのみのupdate時にpasswordがnilになっていてもpassword必須とはならない(allow_nilが利く)
                      length: {               # 最小文字数
                        minimum: 8,
                        allow_blank: true
                      },
                      format: {               # 書式チェック
                        with: VALID_PASSWORD_REGEX,
                        message: :invalid_password,
                        allow_blank: true
                      },
                      allow_nil: true # 空パスワードのアップデートを許容する。(Null(nil)の場合スキップ)

  ## methods
  # class method  ###########################
  class << self
    # emailからアクティブなユーザーを返す
    def find_by_activated(email)
      find_by(email: email, activated: true)
    end
  end
  # class method end #########################

  # 自分以外の同じemailのアクティブなユーザーがいる場合にtrueを返す
  def email_activated?
    users = User.where.not(id: id)
    users.find_by_activated(email).present?
  end

  # リフレッシュトークンのJWT IDを記憶する
  def remember(jti)
    update!(refresh_jti: jti)
  end

  # リフレッシュトークンのJWT IDを削除する
  def forget
    update!(refresh_jti: nil)
  end

  private

    # email小文字化
    def downcase_email
      self.email.downcase! if email
    end
end
