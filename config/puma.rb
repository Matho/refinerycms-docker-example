workers ENV.fetch("RAILS_WORKERS") { 2 }

threads_min = ENV.fetch("RAILS_MIN_THREADS") { 5 }
threads_max = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_min, threads_max

# Specifies the `environment` that Puma will run in
environment ENV.fetch("RAILS_ENV") { "development" }

# Executed in Docker container
if File.exists?('/.dockerenv')
  app_dir = File.expand_path("../..", __FILE__)

  stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true

  bind "unix://#{app_dir}/puma.sock"
else
  # Listen only on port
  port ENV.fetch("PORT") { 3000 }
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
