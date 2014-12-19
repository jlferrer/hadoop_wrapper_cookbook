require 'spec_helper'

describe 'hadoop_wrapper::kerberos_init' do
  context 'on Centos 6.4 x86_64' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: 6.4) do |node|
        node.automatic['domain'] = 'example.com'
        node.automatic['memory']['total'] = '4099400kB'
        node.default['hadoop']['core_site']['hadoop.security.authorization'] = true
        node.default['hadoop']['core_site']['hadoop.security.authentication'] = 'kerberos'
        node.default['krb5']['krb5_conf']['realms']['default_realm'] = 'example.com'
        # Keytab stubs
        %w(hdfs hbase hive jhs mapred yarn zookeeper).each do |kt|
          stub_command("test -e /etc/security/keytabs/#{kt}.service.keytab").and_return(true)
        end
        stub_command('test -e /etc/security/keytabs/yarn.keytab').and_return(true)
        #
        stub_command('test -e /etc/default/hadoop-hdfs-datanode').and_return(true)
        # copied from _jce
        stub_command(/jce(.+).zip' | sha256sum/).and_return(false)
        stub_command(%r{test -e /tmp/jce(.+)/}).and_return(false)
        stub_command(%r{diff -q /tmp/jce(.+)/}).and_return(false)
      end.converge(described_recipe)
    end

    %w(hbase hive zookeeper).each do |user|
      it "creates #{user} user" do
        expect(chef_run).to create_user(user)
      end
    end

    it 'installs kstart package' do
      expect(chef_run).to install_package('kstart')
    end

    it 'creates HTTP/fauxhai.local principal' do
      expect(chef_run).to create_krb5_principal('HTTP/fauxhai.local')
    end

    %w(hdfs hbase hive jhs mapred yarn zookeeper).each do |kt|
      it "creates #{kt}/fauxhai.local principal" do
        expect(chef_run).to create_krb5_principal("#{kt}/fauxhai.local")
      end
      it "creates /etc/security/keytabs/#{kt}.service.keytab" do
        expect(chef_run).to create_krb5_keytab("/etc/security/keytabs/#{kt}.service.keytab")
      end
    end

    it 'creates yarn principal' do
      expect(chef_run).to create_krb5_principal('yarn')
    end

    it 'creates /etc/security/keytabs/yarn.keytab' do
      expect(chef_run).to create_krb5_keytab('/etc/security/keytabs/yarn.keytab')
    end

    %w(modify-etc-default-files kinit-as-hdfs-user).each do |exec|
      it "executes #{exec} resource" do
        expect(chef_run).to run_execute(exec)
      end
    end
  end
end
