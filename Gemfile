source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby
# Compass & foundation
gem 'compass-rails', github: 'Compass/compass-rails', branch: 'master'
gem 'foundation-rails'
gem 'foundation-icons-sass-rails'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Forms made easy!
gem 'simple_form'
gem 'localized_country_select', '>= 0.9.8'

# Markup
gem 'haml-rails', '>= 0.3.4'

# Thin web server
gem 'thin'

# .env (rjb requires JAVA_HOME in .env so we set require here)
gem 'dotenv-rails', :require => 'dotenv/rails-now'

# Use MySQL as the database for Active Record
gem 'mysql2'

# Party!
gem 'httparty'

# Graphs
gem 'ruby-graphviz', '~> 1.2', '>= 1.2.2'
gem 'gnuplot', '~> 2.6', '>= 2.6.2'

# Object#andand
gem 'andand'

# Dictionary
gem 'bilisim_sozlugu'

# Stanford POS Tagger
gem 'rjb'
# gem 'ruby-nlp', :github => 'tiendung/ruby-nlp'

# Neat progressbar
gem 'ruby-progressbar'

# Dump in yaml
gem 'yaml_db'

# jQuery UI for the Rails 3.1+ asset pipeline
# TODO: Add required specific modules to application.js
# https://github.com/joliss/jquery-ui-rails/README.md says:
# "The jQuery UI code weighs 51KB (minified + gzipped) and takes a while to
# execute, so for production apps it's recommended to only include the modules
# that your application actually uses. Dependencies are automatically resolved."
gem 'jquery-ui-rails'

# jquery-datatables gem for rails
gem 'jquery-datatables-rails'

# A ruby gem that uses the Rails asset pipeline to include the jScrollPane plugin by Kelvin Luck
gem 'jscrollpane-rails'

# Pagination
gem 'will_paginate'
gem 'will-paginate-i18n'

# Provides a framework for saving incoming blank values as nil in the database
# in instances where you'd rather use DB NULL than simply a blank string.
gem 'nilify_blanks'

# Filters!
gem 'datagrid'
gem 'font-awesome-rails'
gem 'kaminari'

# Levenshtein distance
gem 'levenshtein-distance'

# Google translate
gem 'google-translate'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # Annotate ActiveRecord models as a gem
  # Note: the beta version has better rails support than the stable 2.5.0
  # (See lib/tasks/auto_annotate_models.rake)
  gem 'annotate'

  gem 'better_errors'
  # better_errors optional dependency (REPL, local/instance variable inspection, pretty stack frame names)
  gem 'binding_of_caller'

  # Help to kill N+1 queries and unused eager loading
  gem 'bullet'

  # Static analysis security scanner for Ruby on Rails
  # http://brakemanscanner.org/docs/options/
  gem 'brakeman'

  # Catches mail and serves it through a dream (!)
  # Run mailcatcher, set your favourite app to deliver to smtp://127.0.0.1:1025
  # instead of your default SMTP server, then check out http://127.0.0.1:1080
  # to see the mail that's arrived so far.
  gem 'mailcatcher'

  # Mutes assets pipeline log messages.
  gem 'quiet_assets'

  # Static code analyzer, syntax checker, code style checker and basic cyclometic complexity analyzer
  gem 'rubocop'

  # Code sad.ist tools
  gem 'flog'
  gem 'flay'

  # Rails codemetric tools
  gem 'rails_best_practices'

  # Has and belongs to many generator
  gem 'habtm_generator'

  # Utilities
  gem 'ansi'
  gem 'html2haml'
  gem 'terminal-table'
  gem 'table_print'
  gem 'tabularize'
  gem 'word_wrap'
end
