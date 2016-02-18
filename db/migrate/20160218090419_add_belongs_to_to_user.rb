class AddBelongsToToUser < ActiveRecord::Migration
  def change
    add_reference :users, :creator_user, :class_name => :User, :foreign_key => "creator_user", :index => true
  end
end
