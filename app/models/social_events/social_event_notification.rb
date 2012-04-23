class SocialEventNotification
  Values = {
      :idea => {
                :created        => 'idea.created',
                :destroyed      => 'idea.destroyed',
                :good           => 'idea.good',
                :ungood       => 'idea.ungood',
                :done           => 'idea.done',
                :undone       => 'idea.undone'
      },
      :user => {
                :following      => 'user.following',
                :followed       => 'user.followed',
                :unfollowed     => 'user.unfollowed'
      }
  }
end