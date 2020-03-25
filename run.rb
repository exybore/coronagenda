require 'discordrb'
require 'sequel'
require 'psych'
require 'date'

require_relative 'lib/storage'

$config = load_yml('config')
$subjects = load_yml('subjects')

DB = Sequel.sqlite($config['db']['path'])

require_relative 'core'

client = Discordrb::Bot.new(
  token: $config['bot']['token'],
  log_mode: $config['bot']['debug'] ? :debug : :quiet,
  fancy_log: true,
  name: $config['meta']['name'],
  client_id: $config['meta']['client_id']
)

client.message(start_with: $config['bot']['prefix']) do |event|
  args = event.content.gsub("\n", '\\n').split(" ")
  command_name = args[0].delete_prefix($config['bot']['prefix'])
  $bot.handle_command(command_name, args[1..], event)
end

client.ready do
  puts "Successfully logged in"
  $bot = Coronagenda::Bot.new(client)
  client.game = "#{$config['bot']['prefix']}help"
end

client.run
