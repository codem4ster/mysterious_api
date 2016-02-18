require 'rails_helper'
require 'fabrication'

RSpec.describe BlogPostController, type: :controller do
  include Devise::TestHelpers

  let(:admin) { Fabricate :user,
                          role: :admin,
                          nickname: 'admin',
                          password: 'admin_pass',
                          email: 'admin@mysite.com' }

  let(:users) { Fabricate.times 25, :user, role: :user, password: 'user_pass' }

  let(:blog_posts) do
    users.reduce([]) do |memo, user|
      memo + Fabricate.times(rand(3..8), :blog_post, user: user)
    end
  end

  let(:guests) do
    Fabricate.times 40, :user, role: :guest, password: 'guest_pass', creator_user: users.sample
  end



  describe "GET #index" do

    describe 'successfull response' do

      def expect_success_on_default(response_data)
        expect(response_data['success']).to eq true
        expect(response_data['page']).to eq 1
        expect(response_data['item_size']).to eq 20
        expect(response_data['total_count']).to eq blog_posts.size
        expect(response_data['blog_posts'].size).to eq 20
      end

      it 'must response with defaults' do
        blog_posts # to create blog posts
        sign_in admin
        get :index
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect_success_on_default response_data
      end

      it 'must response to guest with defaults' do
        blog_posts # to create blog posts
        sign_in guests.sample
        get :index
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect_success_on_default response_data
      end

      it 'must response to user with defaults' do
        blog_posts # to create blog posts
        sign_in users.sample
        get :index
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect_success_on_default response_data
      end

      it 'must response to pagination' do
        blog_posts # to create blog posts
        sign_in admin
        get :index, {page: 2, item_size: 15}
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect(response_data['success']).to eq true
        expect(response_data['page']).to eq 2
        expect(response_data['item_size']).to eq 15
        expect(response_data['total_count']).to eq blog_posts.size
        expect(response_data['blog_posts'].size).to eq 15
      end

    end

    describe 'unsuccessfull response' do

      it 'must give unauthorized access error' do
        get :index
        response_data = JSON.parse(response.body)
        expect(response).to have_http_status(403)
        expect(response_data['success']).to eq false
        expect(response_data['errors']).to eq ["You are not authorized to do this !!!"]
      end

      it 'must give page error' do
        sign_in admin
        get :index, {page: 'corrupted data', item_size: 15}
        response_data = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(response_data['success']).to eq false
        expect(response_data['errors']).to eq ["Page must be greater than 0"]
      end

      it 'must give size error' do
        sign_in admin
        get :index, {page: 1, item_size: 'corrupted data'}
        response_data = JSON.parse(response.body)
        expect(response).to have_http_status(:success)
        expect(response_data['success']).to eq false
        expect(response_data['errors']).to eq ["Item size must be greater than 0"]
      end

    end

  end


  describe "GET #create" do

    def expect_success(request_data, response_data)
      expect(response).to have_http_status(:success)
      expect(response_data['title']).to eq request_data[:title]
      expect(response_data['success']).to eq true
      expect(response_data['description']).to eq request_data[:description]
      expect(response_data['content']).to eq request_data[:content]

      created_blog_post = BlogPost.where(title: request_data[:title]).first
      expect(created_blog_post).not_to be nil
      expect(response_data['blog_post_id']).to eq created_blog_post.id
    end

    def expect_fail(_, response_data)
      expect(response).to have_http_status(403)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq ["You are not authorized to do this !!!"]
    end

    def create_blog_post
      request_data = { title: Faker::Lorem.sentence,
                       description: Faker::Lorem.sentences(2),
                       content: Faker::Lorem.paragraph }
      post :create, request_data
      response_data = JSON.parse(response.body)
      [request_data, response_data]
    end

    describe "successfull response" do

      it "can create blog_post with logged in user" do
        sign_in users.sample
        expect_success(*create_blog_post)
      end

      it "can create blog_post with logged in admin" do
        sign_in admin
        expect_success(*create_blog_post)
      end

    end

    describe "unsuccessfull response" do

      it "can not create blog_post with guest" do
        sign_in guests.sample
        expect_fail(*create_blog_post)
      end

    end


  end


  # Delete update and show tests use this expectations below this line

  let(:user) { users.sample }
  let(:created_blog_post) { Fabricate :blog_post, user: user }
  let(:other_blog_post) { blog_posts.sample }

  def expect_fail(response, message)
    response_data = JSON.parse(response.body)
    expect(response).to have_http_status(:success)
    expect(response_data['success']).to eq false
    expect(response_data['errors']).to eq [message]
  end

  describe "DELETE #destroy" do

    def expect_success(id, response)
      response_data = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(response_data['success']).to eq true
      expect(BlogPost.where(id: id).count).to eq 0
      expect(response_data['blog_post']['id']).to eq id
    end

    def expect_auth_error(id, response)
      response_data = JSON.parse(response.body)
      expect(response).to have_http_status(403)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq ["You are not authorized to do this !!!"]
      expect(BlogPost.where(id: id).count).to be > 0
    end

    it "can only delete blog_posts created by himself with logged in user" do
      sign_in user

      delete :destroy, {id: created_blog_post.id}
      expect_success created_blog_post.id, response

      delete :destroy, {id: other_blog_post.id}
      expect_auth_error other_blog_post.id, response
    end

    it "can delete all blog posts with logged in admin" do
      sign_in admin

      delete :destroy, {id: other_blog_post.id}
      expect_success other_blog_post.id, response
    end

    it "can not delete with guest user" do
      sign_in guests.sample

      delete :destroy, {id: other_blog_post.id}
      expect_auth_error other_blog_post.id, response
    end

    it "must fail when blog_post not found" do
      sign_in admin

      delete :destroy, {id: 'erronous id'}
      expect_fail response, "Blog post cannot be found"
    end
  end

  describe "GET #show" do

    def expect_show_success(id, response)
      response_data = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(response_data['success']).to eq true
      expect(response_data['blog_post']['id']).to eq id
    end

    def expect_show_auth_error(response)
      response_data = JSON.parse(response.body)
      expect(response).to have_http_status(403)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq ["You are not authorized to do this !!!"]
    end

    it "must fail when blog post not found" do
      sign_in admin

      get :show, {id: 'erronous id'}
      expect_fail response, "Blog post cannot be found"
    end

    it "can be shown by any logged in user type" do

      sign_in guests.sample
      get :show, {id: created_blog_post.id}
      expect_show_success created_blog_post.id, response

    end

    it "must give authorization error when user not logged in" do
      get :show, {id: created_blog_post.id}
      expect_show_auth_error response
    end

  end


  describe 'GET #update' do

    def expect_success(request_data, response_data)
      expect(response).to have_http_status(:success)
      expect(response_data['title']).to eq request_data[:title]
      expect(response_data['success']).to eq true
      expect(response_data['description']).to eq request_data[:description]
      expect(response_data['content']).to eq request_data[:content]
      expect(response_data['blog_post_id']).to eq request_data[:id]
    end

    def expect_auth_error(_, response_data)
      expect(response).to have_http_status(403)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq ["You are not authorized to do this !!!"]
    end

    def expect_to_fail(_, response_data, message)
      expect(response).to have_http_status(:success)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq [message]
    end

    def update_blog_post(id = created_blog_post.id)
      request_data = { id: id,
                       title: Faker::Lorem.sentence,
                       description: Faker::Lorem.sentences(2),
                       content: Faker::Lorem.paragraph }
      put :update, request_data
      response_data = JSON.parse(response.body)
      [request_data, response_data]
    end

    it "can be updated by admin" do
      sign_in admin
      expect_success(*update_blog_post)
    end

    it "can only update blog_posts created by himself with logged in user" do
      sign_in user
      expect_success(*update_blog_post)
    end

    it "can not update blog_posts not created by himself with logged in user" do
      sign_in user
      expect_auth_error(*update_blog_post(other_blog_post.id))
    end

    it "can not be updated by guests" do
      sign_in guests.sample
      expect_auth_error(*update_blog_post)
    end

    it "must fail when not find blog post to update" do
      sign_in admin
      expect_to_fail(*update_blog_post('erronous id'), 'Blog post cannot be found')
    end

  end

end
