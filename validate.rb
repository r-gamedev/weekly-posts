require 'pry'
require 'yaml'
require 'redd'
require 'rufus-scheduler'

################################################################################
# Utilities ####################################################################
################################################################################

# The DateTime of the next date matching day.
# ex: date_of_next("Tuesday 19:00")
def date_of_next(day)
  date  = DateTime.parse(day)
  delta = date > DateTime.now ? 0 : 7
  date + delta
rescue
  return nil
end
################################################################################




################################################################################
# Setup ########################################################################
################################################################################

# register all dirs
def validate_all()
  folders = Dir.glob('threads/*').select {|f| File.directory? f}
  folders.each do |dir|
    validate_one(dir)
  end
end

def validate_one(dir)
  # Load
  config = YAML.load_file("#{dir}/config.yaml")
  internal = YAML.load_file("#{dir}/internal.yaml")
  once = YAML.load_file("#{dir}/once.yaml") if File.exist?("#{dir}/once.yaml")
  once_used = YAML.load_file("#{dir}/once-used.yaml") if File.exist?("#{dir}/once-used.yaml")
  posts = YAML.load_file("#{dir}/posts.yaml") if File.exist?("#{dir}/posts.yaml")
  format = File.read("#{dir}/format.md")

  # Declarations
  time, variables = nil, nil

  # config validation
  raise "Could not convert config['time-variance'] to integer" unless config["time-variance"].to_i
  raise "Flair blank." unless config['flair'] and not config['flair'].empty?
  raise "Title blank." unless config['title'] and not config['title'].empty?
  raise "When blank." unless config['when'] and not config['when'].empty?
  raise "No default variables." unless config['variables'] and not config['variables'].empty?

  # attempt to generate time
  begin
    # time validation
    time = date_of_next( "#{config['when']}")
    time += (rand(2*config['time-variance']) - config['time-variance']) / (24.0 * 60.0)
    raise "Time not generated." unless time
    raise "Generated time in the past." if time <= DateTime.now
  rescue # could not generate time
    binding.pry # debug console. use `puts $!, $@` to see the error.
  end

  posts.each do |post|
    # try generating variables
    begin
      variables = config["variables"].merge(post["variables"]).merge(internal)
      variables["today"] = DateTime.now.strftime("%Y-%m-%d")
      variables = variables.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
    rescue # could not generate variables
      binding.pry # debug console. use `puts $!, $@` to see the error.
    end

    # attempt to fill out text
    begin
      title = config["title"] % variables
      text = format % variables
    rescue # could not fill out text
      binding.pry # debug console. use `puts $!, $@` to see the error.
    end
  end

  once.each do |item|
    begin
      before = DateTime.parse(item["before_date"]) if item["before_date"]
      after = DateTime.after(item["after_date"]) if item["after_date"]
      on_counter = item["on_counter"] if item["on_counter"]
      raise "No posting condition given for 'once' post." unless before or after or on_counter
      raise "No default variables." unless config['variables'] and not config['variables'].empty?
    rescue # invalid 'once' post
      binding.pry # debug console. use `puts $!, $@` to see the error.
    end
  end
rescue # unknown error
  binding.pry # debug console. use `puts $!, $@` to see the error.
end

################################################################################
# Run ##########################################################################
################################################################################

if validate_all()
  puts "Validated!"
end