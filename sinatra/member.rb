require 'yaml'

class Member
  attr_reader :username, :name, :password

  def initialize member_hash
    @username = member_hash[:username]
    @name = member_hash[:name]
    @password = member_hash[:password]
  end

  def self.authorize username, password
    if member = find_by_username(username)
      member.password == password
    end
  end

  def self.find_by_username username
    if member_hash = members.select{ |x| x[:username] == username }.first
      Member.new member_hash
    end
  end

  def self.members
    @members ||= YAML::load( IO.popen(self.cmd) { |pipe| pipe.read } )
  end

  private

  def self.cmd
    @_cmd || "/usr/bin/curl #{url}"
  end

  def self.url
    @_url ||= ENV['MEMBERS_GIST_URL']
  end
end
