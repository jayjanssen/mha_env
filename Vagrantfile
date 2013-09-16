# -*- mode: ruby -*-
# vi: set ft=ruby :

# Assumes a box from https://github.com/jayjanssen/packer-percona

# This sets up 2 nodes for replication.  Run 'ms-setup.pl' after these are provisioned.

require './lib/vagrant-common.rb'

# Our puppet config
$puppet_config = {
	'extra_mysqld_config' => "
read_only=1
relay_log_purge=0
"
}

def build_box( config, name, ip, server_id )
	config.vm.define name do |node_config|
		node_config.vm.hostname = name
		node_config.vm.network :private_network, ip: ip

		node_puppet_config = $puppet_config.merge({
			:server_id => server_id
		})

		provider_aws( node_config, name, 'm1.small') { |aws, override|
			aws.block_device_mapping = [
				{
					'DeviceName' => "/dev/sdb",
					'VirtualName' => "ephemeral0"
				}
			]
			provision_puppet( override, 'mha_node.pp', 
				node_puppet_config.merge( 'datadir_dev' => 'xvdb' )
			)
		}

		provider_virtualbox( node_config, '256' ) { |vb, override|		
			provision_puppet( override, 'percona_server.pp', 
				node_puppet_config.merge('datadir_dev' => 'dm-2')
			)

		}

	end
end

Vagrant.configure("2") do |config|
	config.vm.box = "centos-6_4-64_percona"
	config.ssh.username = "root"

	build_box( config, 'd1n1', '192.168.70.2', '1' )
	build_box( config, 'd1n2', '192.168.70.3', '2' )
	build_box( config, 'd2n1', '192.168.70.4', '3' )
	build_box( config, 'd2n2', '192.168.70.5', '4' )

	config.vm.define :manager do |manager_config|
		manager_config.vm.hostname = 'manager'
		manager_config.vm.network :private_network, ip: '192.168.70.5'

		provider_aws( manager_config, 'manager', 'm1.small') { |aws, override|
			aws.block_device_mapping = [
				{
					'DeviceName' => "/dev/sdb",
					'VirtualName' => "ephemeral0"
				}
			]
			provision_puppet( override, 'mha_manager.pp', 
				$puppet_config.merge( 'datadir_dev' => 'xvdb' )
			)
		}

		provider_virtualbox( manager_config, '256' ) { |vb, override|		
			provision_puppet( override, 'percona_server.pp', 
				$puppet_config.merge('datadir_dev' => 'dm-2')
			)

		}

	end

end


