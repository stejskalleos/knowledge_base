# Foreman Console

**Execute db:seed**
```ruby
ForemanInternal.find_by(key: "database_seed")&.destroy
ForemanSeeder.new.execute
```
