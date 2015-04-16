if defined?(ChefSpec)
  def create_percona_config(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:percona_config, :create, resource_name)
  end

  def create_percona_slave_grants(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:percona_slave_grants, :create, resource_name)
  end

  def create_percona_slave_sync(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:percona_slave_sync, :create, resource_name)
  end
end
