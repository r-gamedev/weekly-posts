require 'pry'

# Connect to reddit and make the post.
def connect_and_post(access_conf, title, text)
  r = Redd.it(:script, 
    access_conf['client_id'],
    access_conf['client_secret'],
    access_conf['username'],
    access_conf['password'],
    user_agent: access_conf['useragent'])

  subreddit = r.subreddit_from_name("gamedev")#"bottesting")

  post = nil
  dd = nil
  hot = nil

  connect_and_post_wrap do
    post = subreddit.submit(title, text: text)
  end

  connect_and_post_wrap do
    hot = subreddit.get_hot()
  end

  stickied = hot.select { |p| p[:stickied]}

  dd = stickied.select { |p| p.title.include? "It's the /r/gamedev daily random discussion thread for" }.first

  connect_and_post_wrap do
    stickied.each do |p|
      p.unset_sticky
    end
    post.set_sticky
    dd.set_sticky
  end
rescue
  binding.pry
end

### Override for testing
# def connect_and_post(access_conf, title, text)
#   puts "Would have posted #{title} at #{Time.now}\n\n#{text}"
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
rescue
  binding.pry
end