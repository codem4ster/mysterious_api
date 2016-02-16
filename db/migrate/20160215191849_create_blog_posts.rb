class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.string :description
      t.text :content

      t.belongs_to :user, index: true

      t.timestamps null: false
    end
  end
end
