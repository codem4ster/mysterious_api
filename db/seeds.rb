# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# create an Admin
Fabricate :user, role: :admin, nickname: 'admin', password: 'admin_pass'

# create some users
users = Fabricate.times 5, :user, role: :user, password: 'user_pass'

# and create some blog posts and comments for this users
users.each do |user|
  # let this user to write blog posts between 3 and 8 times
  blog_posts = Fabricate.times(rand(3..8), :blog_post, user: user)
  # and let other users to comment this posts
  other_users = users.select {|other_user| other_user != user }
  blog_posts.each do |post|
    Fabricate.times(rand(4..20), :comment, user: other_users.sample, blog_post: post)
  end
end

# and create some guests to read all of these
Fabricate.times 10, :user, role: :guest, password: 'guest_pass'