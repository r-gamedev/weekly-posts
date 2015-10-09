require 'pry'

SUBREDDIT = "gdevcss"#"gamedev")#"bottesting")
# Connect to reddit and make the post.
def connect_and_post(access_conf, title, text, flair, daily)
  r = Redd.it(:script, 
    access_conf['client_id'],
    access_conf['secret'],
    access_conf['username'],
    access_conf['password'],
    user_agent: access_conf['useragent'])

  connect_and_post_wrap { r.authorize! }

  subreddit = r.subreddit_from_name(SUBREDDIT)

  post = nil
  other = nil
  hot = nil

  connect_and_post_wrap do
    post = subreddit.submit(title, text: text)
  end

  connect_and_post_wrap do
    post = r.from_fullname(post.name).first
  end

  connect_and_post_wrap do
    post.approve!
  end

  connect_and_post_wrap do
    hot = subreddit.get_hot()
  end

  stickied = hot.select { |p| p[:stickied]}

  if daily
    other = stickied.select { |p| !p.title.include? "It's the /r/gamedev daily random discussion thread for" }.first
  else
    other = stickied.select { |p| p.title.include? "It's the /r/gamedev daily random discussion thread for" }.first
  end

  connect_and_post_wrap do
    stickied.each do |p|
      p.unset_sticky
    end
    if daily
      other.set_sticky
      post.set_sticky
    else
      post.set_sticky
      other.set_sticky
    end
    subreddit.set_flair(post, nil, flair)
  end
rescue
  binding.pry
end


def connect_and_error(access_conf, error)
  r = Redd.it(:script, 
    access_conf['client_id'],
    access_conf['secret'],
    access_conf['username'],
    access_conf['password'],
    user_agent: access_conf['useragent'])

  connect_and_post_wrap { r.authorize! }

  connect_and_post_wrap do
    subreddit = r.subreddit_from_name(SUBREDDIT)#"gamedev")#"bottesting")
    subreddit.send_message("Error in Weekly Autoposter", "#{Time.now}\n\n#{error}")
  end
rescue
  binding.pry
end

## Override for testing
# def connect_and_post(access_conf, title, text, flair)
#   puts "Would have posted #{title} at #{Time.now}\n\n#{text} with flair: #{flair}"
# end

# Helper for connect_and_post;
# performs the action in the block until it is successful;
# drops to console if the error could not be handled
def connect_and_post_wrap
  yield
rescue Redd::Error::RateLimited => error
  sleep(error.time)
  retry
rescue Redd::Error => error
  # 5-something errors are usually errors on reddit's end.
  raise error unless (500...600).include?(error.code)
  retry
end