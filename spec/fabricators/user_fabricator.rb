Fabricator(:user) do
  name { Faker::Name.name }
  nickname { |items| Faker::Internet.user_name(items[:name]) }
  email { |items| Faker::Internet.email(items[:name]) }
  password { Faker::Internet.password 8 }
  role { [:user, :guest, :admin].sample }
  confirmed_at { Time.now }
end