Fabricator(:comment) do
  title { Faker::Lorem.sentence }
  message { Faker::Lorem.sentences 3 }
  user { Fabricate.build :user }
  blog_post { Fabricate.build :blog_post }
end