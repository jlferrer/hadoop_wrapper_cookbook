
bash 'chown_hadoop_hdfs' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    chown -R hdfs:hadoop /var/log/hadoop-hdfs  
  EOH
end

if !node['hadoop'].attribute?('rspec') && Chef::Config[:solo]
  Chef::Log.warn('This recipe uses partial_search. Chef Solo does not support search.')
else
  datanodes = search(
    :node, \
    "role:#{node['hadoop']['datanode_role']} AND chef_environment:#{node.chef_environment}").each do |data_node|

    hostsfile_entry data_node['network']['interfaces'][node['hadoop']['datanode_iface']]['addresses'].keys[1] do
      hostname  data_node['fqdn']
      unique    true
    end
  end

end


ruby_block 'service-hadoop-hdfs-namenode-start-and-enable' do
  block do
    %w(enable start).each do |action|
      resources('service[hadoop-hdfs-namenode]').run_action(action.to_sym)
    end
  end
end

