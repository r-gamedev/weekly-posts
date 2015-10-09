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
  time = date_of_next( "#{config['when']}")
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

def pop_appropriate_post(once, counter)
  selected_index = nil
  once.each_with_index do |item, index|

    before = DateTime.parse(item["before_date"]) if item["before_date"]
    after = DateTime.after(item["after_date"]) if item["after_date"]
    on_counter = item["on_counter"] if item["on_counter"]

    if counter == on_counter
      selected_index = index
      break
    end

    if before <= DateTime.now && (before + 7) > DateTime.now
      selected_index = index
      break
    end

    if (after - 7) <= DateTime.now && after > DateTime.now
      selected_index = index
      break
    end
  end

  if selected_index
    return once.delete_at(selected_index)
  else
    return nil
  end
end

# Generates a post and submits it
def make_post(dir)
  puts "make a post for #{dir} at #{Time.now}"

  # Load
  config = YAML.load_file("#{dir}/config.yaml")
  internal = YAML.load_file("#{dir}/internal.yaml")
  once = YAML.load_file("#{dir}/once.yaml")
  once_used = YAML.load_file("#{dir}/once-used.yaml")
  posts = YAML.load_file("#{dir}/posts.yaml")
  format = File.read("#{dir}/format.md")

  # find an appropriate post, if available
  post = pop_appropriate_post(once, internal["counter"])
  if post # if we found one, move it to posts/once-used, as appropriate
    post["last-used-on"] = Time.now.to_s
    if posts["again"] # if we're using it again, just put it back where we found it
      once.push post
    else
      # clear out the settings
      post.delete("before-date")
      post.delete("after-date")
      post.delete("on-counter")
      if post["keep"] # onward to posts.yaml
        posts.push post
        posts.delete("keep")
        File.open("#{dir}/posts.yaml", "w") { |f| f.write posts.to_yaml }
      else #onward to once-used.yaml
        poasts.delete("keep")
        once_used.push post
        File.open("#{dir}/once-used.yaml", "w") { |f| f.write once_used.to_yaml }
      end
    end
    File.open("#{dir}/once.yaml", "w") { |f| f.write once.to_yaml }
  else # if we didn't find one, grab one from posts
    if posts.empty?
      post = {"variables"=> {}}
    else
      # take the first element and move it to the end, save the change
      post = posts.shift
      post["last-used-on"] = Time.now.to_s
      posts.push post
      File.open("#{dir}/posts.yaml", "w") { |f| f.write posts.to_yaml }
    end
  end

  # generate variables
  variables = config["variables"].merge(post["variables"]).merge(internal)
      variables["today"] = DateTime.now.strftime("%Y-%m-%d")

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

# make_post('threads/mm')


connect_and_post(@access_conf, "FF Test 2", "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque porttitor ligula ut posuere tincidunt. Donec suscipit dapibus augue non mollis. Cras aliquam enim quis justo aliquet semper. Mauris id semper lorem. Pellentesque id libero metus. Nam sagittis, arcu in vehicula viverra, purus massa semper diam, vel consectetur metus elit sed turpis. Phasellus laoreet malesuada lorem, eget posuere erat laoreet et. In blandit blandit orci ut hendrerit. In vitae lorem nec massa efficitur dictum.

Nulla facilisis facilisis volutpat. Ut ultrices, justo sit amet pulvinar imperdiet, orci enim iaculis lorem, ut rutrum est enim a diam. Donec nunc massa, elementum quis eleifend ac, egestas ac felis. Morbi sodales urna vel pretium varius. Nullam quis mi a ante aliquam euismod ut nec nisi. Nam egestas, nibh sit amet ultrices dapibus, nibh dolor scelerisque turpis, sed tristique dolor ligula vitae dolor. Curabitur gravida lorem tortor, eget vehicula lacus viverra nec. Integer commodo pulvinar nibh, eget sollicitudin ante dignissim eget. Morbi consectetur orci eu velit vestibulum tristique.", "FF")

# wait
binding.pry

# just in case
@scheduler.join