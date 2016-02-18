require 'rails_helper'
require 'fabrication'

RSpec.describe UserController, type: :controller do
  include Devise::TestHelpers

  let(:admin) { Fabricate :user,
                          role: :admin,
                          nickname: 'admin',
                          password: 'admin_pass',
                          email: 'admin@mysite.com' }

  let(:users) { Fabricate.times 25, :user, role: :user, password: 'user_pass' }


  let(:guests) do
    Fabricate.times 40, :user, role: :guest, password: 'guest_pass', creator_user: users.sample
  end



  describe "GET #index" do

    describe 'successfull response' do

      def expect_success_on_default(response_data)
        expect(response_data['success']).to eq true
        expect(response_data['page']).to eq 1
        expect(response_data['item_size']).to eq 20
        expect(response_data['total_count']).to eq @all_users.size
        expect(response_data['users'].size).to eq 20
      end

      it 'must response with defaults' do
        @all_users = [admin] + users + guests
        sign_in admin
        get :index
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect_success_on_default response_data
      end

      it 'must response to guest with defaults' do
        @all_users = [admin] + users + guests
        sign_in guests.sample
        get :index
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect_success_on_default response_data
      end

      it 'must response to user with defaults' do
        @all_users = [admin] + users + guests
        sign_in users.sample
        get :index
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect_success_on_default response_data
      end

      it 'must response to pagination' do
        all_users = [admin] + users + guests
        sign_in admin
        get :index, {page: 2, item_size: 15}
        expect(response).to have_http_status(:success)
        response_data = JSON.parse(response.body)
        expect(response_data['success']).to eq true
        expect(response_data['page']).to eq 2
        expect(response_data['item_size']).to eq 15
        expect(response_data['total_count']).to eq all_users.size
        expect(response_data['users'].size).to eq 15
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
      expect(response_data['name']).to eq request_data[:name]
      expect(response_data['success']).to eq true
      expect(response_data['nickname']).to eq request_data[:nickname]
      expect(response_data['email']).to eq request_data[:email]

      created_user = User.where(nickname: request_data[:nickname], email: request_data[:email]).first
      expect(created_user).not_to be nil
      expect(response_data['user_id']).to eq created_user.id
    end

    def expect_fail(_, response_data)
      expect(response).to have_http_status(403)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq ["You are not authorized to do this !!!"]
    end

    def create_user(role: 'user', password: Faker::Internet.password(8))
      name = Faker::Name.name
      request_data = { name: name,
                       nickname: Faker::Internet.user_name(name),
                       email: Faker::Internet.email(name),
                       password: password, role: role }
      post :create, request_data
      response_data = JSON.parse(response.body)
      [request_data, response_data]
    end

    describe "successfull response" do

      it "can create another user with logged in user" do
        sign_in users.sample
        expect_success(*create_user)
      end

      it "can create another user with logged in admin" do
        sign_in admin
        expect_success(*create_user)
      end

    end

    describe "unsuccessfull response" do

      it "can not create admin with logged in user" do
        sign_in users.sample
        expect_fail(*create_user(role: 'admin'))
      end

      it "can not create any type of user with logged in guest" do
        sign_in guests.sample
        expect_fail(*create_user(role: 'guest'))
        expect_fail(*create_user(role: 'user'))
        expect_fail(*create_user(role: 'admin'))
      end

      it "must give validation error" do
        sign_in admin
        _, response_data = create_user password: Faker::Internet.password(3, 6)
        expect(response).to have_http_status(:success)
        expect(response_data['success']).to eq false
        expect(response_data['errors']).to eq ['password ["is too short (minimum is 8 characters)"]']
      end

    end


  end


  # Delete and show tests use this expectations below this line

  let(:user) { users.sample }
  let(:created_guest) { Fabricate :user, role: :guest, password: 'guest_pass', creator_user: user }
  let(:another_guest) { guests.find {|g| g.creator_user != user } }
  let(:another_admin) { Fabricate :user,
                                  role: :admin,
                                  nickname: 'admin2',
                                  password: 'admin2_pass',
                                  email: 'admin2@mysite.com' }

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
      expect(User.where(id: id).count).to eq 0
      expect(response_data['user']['id']).to eq id
    end

    def expect_auth_error(id, response)
      response_data = JSON.parse(response.body)
      expect(response).to have_http_status(403)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq ["You are not authorized to do this !!!"]
      expect(User.where(id: id).count).to be > 0
    end

    it "can only delete users created by himself with logged in user" do
      sign_in user

      delete :destroy, {id: created_guest.id}
      expect_success created_guest.id, response

      delete :destroy, {id: another_guest.id}
      expect_auth_error another_guest.id, response
    end

    it "can delete all type of user with logged in admin except self" do
      sign_in admin

      delete :destroy, {id: another_guest.id}
      expect_success another_guest.id, response

      delete :destroy, {id: another_admin.id}
      expect_success another_admin.id, response

      delete :destroy, {id: admin.id}
      expect_auth_error admin.id, response
    end

    it "can not delete with guest user" do
      sign_in another_guest

      delete :destroy, {id: created_guest.id}
      expect_auth_error created_guest.id, response
    end

    it "must fail when user not found" do
      sign_in admin

      delete :destroy, {id: 'erronous id'}
      expect_fail response, "User cannot be found"
    end
  end

  describe "GET #show" do

    def expect_show_success(id, response)
      response_data = JSON.parse(response.body)
      expect(response).to have_http_status(:success)
      expect(response_data['success']).to eq true
      expect(response_data['user']['id']).to eq id
    end

    def expect_show_auth_error(response)
      response_data = JSON.parse(response.body)
      expect(response).to have_http_status(403)
      expect(response_data['success']).to eq false
      expect(response_data['errors']).to eq ["You are not authorized to do this !!!"]
    end

    it "must fail when user not found" do
      sign_in admin

      get :show, {id: 'erronous id'}
      expect_fail response, "User cannot be found"
    end

    it "can be shown by any logged in user type" do

      sign_in guests.sample
      get :show, {id: user.id}
      expect_show_success user.id, response

    end

    it "must give authorization error when user not logged in" do
      get :show, {id: user.id}
      expect_show_auth_error response
    end

  end

end
