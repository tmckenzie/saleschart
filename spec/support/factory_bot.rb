# RSpec.configure do |config|
#   config.include FactoryBot::Syntax::Methods
# end
# require 'factory_bot'
# FactoryBot.find_definitions

puts "Seeding..."
puts "Defaults ..."

master = Master.create(name: 'Master Account')
ma = Account.create(accountable: master)

puts "  seeding admin users"
%w(admin@mmp.com).each do |user|
  admin = User.create(email: user, password: 'MMPpass4adm1n', password_confirmation: 'MMPpass4adm1n', account: ma, vendor_admin: false)
end