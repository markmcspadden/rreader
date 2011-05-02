class Comment < ActiveRecord::Base

  belongs_to :post
  
  def post_title
    post.title
  end

end
