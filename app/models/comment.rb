class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :blog_post

  def self.editable_column_names
    @editable_columns ||= [ :title, :message ]
  end

  scope :in_page, ->(page, with_size: 20) {
    offset = (page.to_i-1) * with_size.to_i
    limit(with_size.to_i).offset(offset)
  }
end
