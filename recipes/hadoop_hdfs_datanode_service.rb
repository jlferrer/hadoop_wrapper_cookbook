
if !node['hadoop'].attribute?('rspec') && Chef::Config[:solo]
  Chef::Log.warn('This recipe uses partial_search. Chef Solo does not support search.')
else
  namenode = search(
    :node, \
    "role:#{node['hadoop']['namenode_role']} AND chef_environment:#{node.chef_environment}")
end

hostsfile_entry namenode[0]['hadoop']['hdfs_site']['dfs.namenode.rpc-bind-host'] do
  hostname  node['hadoop']['namenode_name']
  unique    true
end

bash 'chown_hadoop_hdfs' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    chown -R hdfs:hadoop /var/log/hadoop-hdfs  
  EOH
end

# Execute hte service 
ruby_block 'service-hadoop-hdfs-datanode-start-and-enable' do
  block do
    %w(enable start).each do |action|
      resources('service[hadoop-hdfs-datanode]').run_action(action.to_sym)
    end
  end
end
