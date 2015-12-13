namespace :cts do
  desc 'Rebuild database from scratch with base data'
  task :rebuilddb => [
    'db:drop',
    'db:create',
    'db:migrate',
    'db:seed'
  ]
end

