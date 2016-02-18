class BlogPost < ActiveRecord::Base
  belongs_to :user
  has_many :comments

  def self.editable_column_names
    @editable_columns ||= [ :title, :description, :content ]
  end

  scope :in_page, ->(page, with_size: 20) {
    offset = (page.to_i-1) * with_size.to_i
    limit(with_size.to_i).offset(offset)
  }
end
