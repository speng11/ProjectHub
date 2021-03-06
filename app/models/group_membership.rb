class GroupMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates :user_id, :presence => true
  validates :group_id, :presence => true
  validates :is_admin, :inclusion => { :in => [true, false] }
end
