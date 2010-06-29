### A little sinatra gem that implements user authentication, with support for DataMapper.

(Forked from maxjustus' version.  I don't need TC or Mongo, nor Facebook integration)

## INSTALLATION:

In your sinatra app simply require "dm-core", "digest/sha1", 'rack-flash' (if you want flash messages) and then "sinatra-authentication" and turn on session storage with a super secret key, like so:

    require "dm-core"
    #for using auto_migrate!
    require "dm-migrations"
    require "digest/sha1"
    require 'rack-flash'
    require "sinatra-authentication"

    use Rack::Session::Cookie, :secret => 'A1 sauce 1s so good you should use 1t on a11 yr st34ksssss'
    #if you want flash messages
    use Rack::Flash

## DEFAULT ROUTES:

* get      '/login'
* get      '/logout'
* get      '/signup'
* get/post '/users'
* get       '/users/:id'
* get/post  '/users/:id/edit'
* get       '/users/:id/delete'

If you fetch any of the user pages using ajax, they will automatically render without a layout

## ADDITIONAL ROUTES WHEN USING SINBOOK FOR FACEBOOK INTEGRATION:

* get      '/reciever'
* get      '/connect'

## FLASH MESSAGES

Flash messages are implemented using rack-flash. To set them up add this to your code:

    require 'rack-flash'

    #be sure and do this after after 'use Rack:Session:Cookie...'
    use Rack::Flash

And then sinatra-authentication related flash messages will be made available through flash[:notice]

    -# somewhere in a haml view:
    = flash[:notice]

## HELPER METHODS:

This plugin provides the following helper methods for your sinatra app:

* login_required
  > which you place at the beginning of any routes you want to be protected
* current_user
* logged_in?
* render_login_logout(html_attributes)
  > Which renders login/logout and singup/edit account links.
If you pass a hash of html parameters to render_login_logout all the links will get set to them.
Which is useful for if you're using some sort of lightbox

## SIMPLE PERMISSIONS:

By default the user class includes a method called admin? which simply checks
if user.permission_level == -1.

you can take advantage of  this method in your views or controllers by calling
current_user.admin?
i.e.

    - if current_user.admin?
      %a{:href => "/adminey_link_route_thing"} do something adminey

(these view examples are in HAML, by the way)

You can also extend the user class with any convenience methods for determining permissions.
i.e.

    #somewhere in the murky depths of your sinatra app
    class User
      def peasant?
        self.permission_level == 0
      end
    end

then in your views you can do

    - if current_user.peasant?
      %h1 hello peasant!
      %p Welcome to the caste system! It's very depressing.

if no one is logged in, current_user returns a GuestUser instance, which responds to current_user.guest?
with true, current_user.permission_level with 0 and any other method calls with false

This makes some view logic easier since you don't always have to check if the user is logged in,
although a logged_in? helper method is still provided


## OVERRIDING DEFAULT VIEWS

Right now if you're going to override sinatra-authentication's views, you have to override all of them.
This is something I hope to change in a future release.

To override the default view path do something like this:

    set :sinatra_authentication_view_path, Pathname(__FILE__).dirname.expand_path + "my_views/"

And then the views you'll need to define are:

* show.haml
* index.haml
* signup.haml
* login.haml
* edit.haml

The signup and edit form fields are named so they pass a hash called 'user' to the server:

    %input{:name => "user[email]", :size => 30, :type => "text", :value => @user.email}
    %input{:name => "user[password]", :size => 30, :type => "password"}
    %input{:name => "user[password_confirmation]", :size => 30, :type => "password"}

    %select{:name => "user[permission_level]"}
      %option{:value => -1, :selected => @user.admin?}
        Admin
      %option{:value => 1, :selected => @user.permission_level == 1}
        Authenticated user

if you add attributes to the User class and pass them in the user hash your new attributes will be set along with the others.

The login form fields just pass a field called email and a field called password:

    %input{:name => "email", :size => 30, :type => "text"}
    %input{:name => "password", :size => 30, :type => "password"}

To add methods or properties to the User class, you have to access the underlying database user class, like so:

    class DmUser
      property :name, String
      property :has_dog, Boolean, :default => false
    end

And then to access/update your newly defined attributes you use the User class:

    current_user.name
    current_user.has_dog

    current_user.update({:has_dog => true})

    new_user = User.set({:email => 'max@max.com' :password => 'hi', :password_confirmation => 'hi', :name => 'Max', :has_dog => false})

    User.all(:has_dog => true).each do |user|
      user.update({has_dog => false})
    end

    User.all(:has_dog => false).each do |user|
      user.delete
    end

the User class passes additional method calls along to the interfacing database class, so calls to Datamapper functions should work as expected.

The database user class is named :

* for Datamapper:
  > DmUser

