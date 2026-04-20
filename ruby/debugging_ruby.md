# Debugging Ruby

Ruby method and constant location
```ruby
Object.const_source_location(imgs.first.class.to_s)
@host.method(:write_attribute).source_location
```

Debugging models:
```ruby
  before_create do
    debugger
  end
```

Listing methods
```ruby
ClassOrModule.methods
ClassOrModule.public_instance_methods
ClassOrModule.private_instance_methods
```

Gems
```
gem which rbvmomi
cd $(dirname $(gem which rbvmomi))
```
