require 'pry'
require 'yaml'
require 'redd'
require 'rufus-scheduler'
require './connect.rb'

@access_conf = YAML.load_file("access.conf.yaml")

#connect_and_post(@access_conf, "Test", "Testing")

@scheduler = Rufus::Scheduler.new


################################################################################
# Utilities ####################################################################
################################################################################

# The DateTime of the next date matching day.
# ex: date_of_next("Tuesday 19:00")
def date_of_next(day)
  date  = DateTime.parse(day)
  delta = date > DateTime.now ? 0 : 7
  date + delta
end
################################################################################




################################################################################
# Setup ########################################################################
################################################################################

# register all dirs
def register()
  folders = Dir.glob('threads/*').select {|f| File.directory? f}
  folders.each do |dir|
    register_dir(dir)
  end
end

# register a dir's tasks
def register_dir(dir)
  return if dir.downcase.include? 'example'
  config = YAML.load_file("#{dir}/config.yaml")
  time = date_of_next( "#{config['day']} #{config['time']}")
  time += (rand(2*config['time-variance']) - config['time-variance']) / (24.0 * 60.0)
  schedule time do
    make_post(dir);
  end
rescue
  binding.pry
end

# schedules a task in a non-verlapping fashion, avoids scheduling in the past
def schedule(time)
  raise "Time in the past." if time <= DateTime.now
  @scheduler.at time.to_s, overlap: false do
    yield
  end
rescue
  binding.pry
end

# Generates a post and submits it
def make_post(dir)
  puts "make a post for #{dir} at #{Time.now}"

  # Load
  config = YAML.load_file("#{dir}/config.yaml")
  internal = YAML.load_file("#{dir}/internal.yaml")
  posts = YAML.load_file("#{dir}/posts.yaml")
  format = File.read("#{dir}/format.md")

  # take the first element and move it to the end, save the change
  post = posts.shift
  posts.push post
  File.open("#{dir}/posts.yaml", "w") { |f| f.write posts.to_yaml }

  # generate variables
  variables = config["variables"].merge(post["variables"]).merge(internal)

  #symbolize the hash
  variables = variables.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  title = config["title"] % variables
  text = format % variables

  # increment internal counter and save
  internal["counter"] += 1;
  File.open("#{dir}/internal.yaml", "w") { |f| f.write internal.to_yaml }

  connect_and_post(@access_conf, title, text, config["flair"])

  # save the changes to the git
  `git pull`
  `git add /threads*`
  `git commit -m "Post updates"`
  `git push`

  # reschedule
  @scheduler.in '1m', overlap: false do
    register_dir(dir)
  end
rescue
  binding.pry
end

################################################################################
# Run ##########################################################################
################################################################################

# register the date-times
# register()

make_post('threads/mm')

# wait
binding.pry

# just in case
@scheduler.join