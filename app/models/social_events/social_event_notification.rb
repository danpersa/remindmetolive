class SocialEventNotification
  Values = {
      :idea => {
                :created        => 'idea.created',
                :destroyed      => 'idea.destroyed',
                :done           => 'idea.done',
                :good           => 'idea.good'
      },
      :user => {
                :following      => 'user.following',
                :followed       => 'user.followed',
                :unfollowed     => 'user.unfollowed'
      }
  }
end