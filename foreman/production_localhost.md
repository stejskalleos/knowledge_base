# Running Foreman in production mode on localhost
config/database.yml 
```
production:
  adapter: postgresql
  host: localhost
  username: postgres
  password: changeme
  pool: 5
  database: sat_foreman
```

Cleanup
```
rm -rf public/assets/* public/webpack/* tmp/*
```

Update gems and npm packages (if needed)
```
rm Gemfile.lock;bundle install
clear;rm -rf node_modules package-json.lock tmp/*;npm cache clean --force;npm install
```
Database
```
RAILS_ENV=production be rake db:create
RAILS_ENV=production be rake db:migrate
RAILS_ENV=production be rake db:seed
RAILS_ENV=production be rake permissions:reset username=admin password=changeme
```

Compile JS & Assets
```
RAILS_ENV=production be rails webpack:compile
RAILS_ENV=production be rails assets:precompile
```

Run Rails
```
RAILS_ENV=production RAILS_SERVE_STATIC_FILES=true bundle exec ./bin/rails s -b localhost -p 3000
```
