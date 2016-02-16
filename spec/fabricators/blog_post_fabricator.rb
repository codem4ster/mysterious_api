Fabricator(:blog_post) do
  title { Faker::Lorem.sentence }
  description { Faker::Lorem.sentences 2 }
  content { Faker::Lorem.paragraph }
  user { Fabricator.build :user }
end