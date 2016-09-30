require File.expand_path('server', File.dirname(__FILE__))

use Rack::SSL if ENV['RAILS_ENV'] == "production"

run GithubStatistics.app
