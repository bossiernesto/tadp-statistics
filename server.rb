require 'bundler/setup'
require 'sinatra'
require 'rest_client'
require 'json'

require "rubygems"
require 'rack/ssl'
require 'sinatra/auth/github'
require_relative 'highchart'

module GithubStatistics

  class BadAuthentication < Sinatra::Base
    get '/unauthenticated' do
      status 403
      <<-EOS
      <h2>Unable to authenticate at this time.</h2>
      <p>#{env['warden'].message}</p>
      EOS
    end
  end

  class SimpleApp < Sinatra::Base

    enable :sessions
    enable :raise_errors
    disable :show_exceptions
    enable :inline_templates

    # !!! DO NOT EVER USE HARD-CODED VALUES IN A REAL APP !!!
    # Set them in as keys in the enviroment/config of the instance
    CLIENT_ID = ENV['GITHUB_CLIENT_ID'] || ''
    CLIENT_SECRET = ENV['GITHUB_CLIENT_SECRET'] || ''

    set :github_options, {
                           :scopes => 'user, repo, org',
                           :secret => CLIENT_SECRET,
                           :client_id => CLIENT_ID
                       }

    register Sinatra::Auth::Github

    get '/' do
      erb :index
    end

    get '/profile' do
      authenticate!
      erb :profile
    end

    get '/login' do
      authenticate!
      redirect '/'
    end

    get '/logout' do
      logout!
      redirect '/'
    end

    get '/dashboard' do
      authenticate!
      @orgs = github_user.api.organizations
      @user = github_user

      @chart = HighChart.new do |chart|
        chart.title_text = "Combination Chart"
        chart.x_categories = ['Pears', 'Bananas', 'Plums']
        chart.series_data = {
            "Calvin" => [10, 2, 17],
            "Hobbes" => [11, 14, 6]
        }
      end

      erb :dashboard_general, :layout => :dashboard_layout
    end

    get '/organization/view/:organization' do
      authenticate!

      @organization = params[:organization]
      @repos = github_user.api.organization_repositories params[:organization]

      erb :organization_repos, :layout => :dashboard_layout
    end

    get '/repo/view/:organization/:repo' do
      authenticate!

      @organization = params[:organization]
      @repo_name = params[:repo]

      @repo_path = "#{@organization}/#{@repo_name}"

      @repo = github_user.api.repository @repo_path

      erb :repository_general, :layout => :dashboard_layout
    end
  end

  def self.app
    @app ||= Rack::Builder.new do
      run SimpleApp
    end
  end

end
