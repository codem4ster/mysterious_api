require 'rails_helper'
require 'fabrication'

RSpec.describe CommentController, type: :controller do
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

  let(:comments) do
    blog_posts.reduce([]) do |memo, post|
      memo + Fabricate.times(rand(4..20), :comment, user: users.sample, blog_post: post)
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
        expect(response_data['total_count']).to eq comments.size
        expect(response_data['comments'].size).to eq 20
      end

      it 'must response with defaults' do
        comments # to create comments
        sign_in admin
        get :index
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect_success_on_default response_data
      end

      it 'must response to guest with defaults' do
        comments # to create comments
        sign_in guests.sample
        get :index
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect_success_on_default response_data
      end

      it 'must response to user with defaults' do
        comments # to create blog posts
        sign_in users.sample
        get :index
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect_success_on_default response_data
      end

      it 'must response to pagination' do
        comments # to create blog posts
        sign_in admin
        get :index, {page: 2, item_size: 15}
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect(response_data['success']).to eq true
        expect(response_data['page']).to eq 2
        expect(response_data['item_size']).to eq 15
        expect(response_data['total_count']).to eq comments.size
        expect(response_data['comments'].size).to eq 15
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
      expect(response_data['message']).to eq request_data[:message]

      created_comment = Comment.where(title: request_data[:title]).first
      expect(created_comment).not_to be nil
      expect(response_data['comment_id']).to eq created_comment.id
    end

    def expect_fail(_, response_data)
      expect(response).to have_http_status(403)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq ["You are not authorized to do this !!!"]
    end

    def expect_error_msg(_, response_data, msg)
      expect(response).to have_http_status(:success)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq [msg]
    end

    def create_comment(blog_post_id= blog_posts.sample.id)
      request_data = { title: Faker::Lorem.sentence,
                       message: Faker::Lorem.sentence(2),
                       blog_post_id: blog_post_id }
      post :create, request_data
      response_data = JSON.parse(response.body)
      [request_data, response_data]
    end

    describe "successfull response" do

      it "can create comment with logged in user" do
        sign_in users.sample
        expect_success(*create_comment)
      end

      it "can create comment with logged in admin" do
        sign_in admin
        expect_success(*create_comment)
      end

    end

    describe "unsuccessfull response" do

      it "must fail when blog post is missing" do
        sign_in users.sample
        expect_error_msg(*create_comment(nil), 'Cannot find blog post to be commented')
      end

      it "can not create comment with guest" do
        sign_in guests.sample
        expect_fail(*create_comment)
      end

    end


  end


  # Delete and show tests use this expectations below this line

  let(:user) { users.sample }
  let(:blog_post) { blog_posts.sample }
  let(:created_comment) { Fabricate :comment, user: user, blog_post: blog_post }
  let(:other_comment) { comments.sample }

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
      expect(Comment.where(id: id).count).to eq 0
      expect(response_data['comment']['id']).to eq id
    end

    def expect_auth_error(id, response)
      response_data = JSON.parse(response.body)
      expect(response).to have_http_status(403)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq ["You are not authorized to do this !!!"]
      expect(Comment.where(id: id).count).to be > 0
    end

    it "can only delete comments created by himself with logged in user" do
      sign_in user

      delete :destroy, {id: created_comment.id}
      expect_success created_comment.id, response

      delete :destroy, {id: other_comment.id}
      expect_auth_error other_comment.id, response
    end

    it "can delete all blog posts with logged in admin" do
      sign_in admin

      delete :destroy, {id: other_comment.id}
      expect_success other_comment.id, response
    end

    it "can not delete with guest user" do
      sign_in guests.sample

      delete :destroy, {id: other_comment.id}
      expect_auth_error other_comment.id, response
    end

    it "must fail when comment not found" do
      sign_in admin

      delete :destroy, {id: 'erronous id'}
      expect_fail response, "Comment cannot be found"
    end
  end

  describe "GET #show" do

    def expect_show_success(id, response)
      response_data = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(response_data['success']).to eq true
      expect(response_data['comment']['id']).to eq id
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
      expect_fail response, "Comment cannot be found"
    end

    it "can be shown by any logged in user type" do

      sign_in guests.sample
      get :show, {id: created_comment.id}
      expect_show_success created_comment.id, response

    end

    it "must give authorization error when user not logged in" do
      get :show, {id: created_comment.id}
      expect_show_auth_error response
    end

  end

  describe 'GET #update' do

    def expect_success(request_data, response_data)
      expect(response).to have_http_status(:success)
      expect(response_data['title']).to eq request_data[:title]
      expect(response_data['success']).to eq true
      expect(response_data['message']).to eq request_data[:message]
      expect(response_data['comment_id']).to eq request_data[:id]
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

    def update_comment(id = created_comment.id)
      request_data = { id: id,
                       title: Faker::Lorem.sentence,
                       message: Faker::Lorem.sentences(2).join(' ') }
      put :update, request_data
      response_data = JSON.parse(response.body)
      [request_data, response_data]
    end

    it "can be updated by admin" do
      sign_in admin
      expect_success(*update_comment)
    end

    it "can only update comments created by himself with logged in user" do
      sign_in user
      expect_success(*update_comment)
    end

    it "can not update comments not created by himself with logged in user" do
      sign_in user
      expect_auth_error(*update_comment(other_comment.id))
    end

    it "can not be updated by guests" do
      sign_in guests.sample
      expect_auth_error(*update_comment)
    end

    it "must fail when not find comment to update" do
      sign_in admin
      expect_to_fail(*update_comment('erronous id'), 'Comment cannot be found')
    end

  end

end
