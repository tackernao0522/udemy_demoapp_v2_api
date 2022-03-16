10.times do |n|
  name = "user#{n}"
  email = "#{name}@example.com"
  # find_by(email: email, activated: true)
  # オブジェクトが存在する => 取得
  # オブジェクトが存在しない => User.new(email: email, activated: true)
  user = User.find_or_initialize_by(email: email, activated: true)

  if user.new_record?
    user.name = name
    user.password = "password"
    user.save!
  end
end

puts "users = #{User.count}"
