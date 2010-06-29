if Object.const_defined?("DataMapper")
  #require 'dm-core'
  require 'dm-timestamps'
  require 'dm-validations'
  require Pathname(__FILE__).dirname.expand_path + "datamapper_user.rb"
  require Pathname(__FILE__).dirname.expand_path + "dm_adapter.rb"
end

class User
  if Object.const_defined?("DataMapper")
    include DmAdapter
  else
    throw "you need to require 'dm-core' for sinatra-authentication to work"
  end

  def initialize(interfacing_class_instance)
    @instance = interfacing_class_instance
  end

  def id
    @instance.id
  end

  def self.authenticate(email, pass)
    current_user = get(:email => email)
    return nil if current_user.nil?
    return current_user if User.encrypt(pass, current_user.salt) == current_user.hashed_password
    nil
  end

  protected

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end

  def self.random_string(len)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end
end
