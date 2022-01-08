Vagrant.configure("2") do |config|
	config.vm.define "project" do |project|
		project.vm.box = "bento/ubuntu-20.04"
		project.vm.hostname = "project"
		project.vm.network "forwarded_port", guest: 3001, host: 8080
		project.vm.provider "virtualbox" do |vb|
			vb.memory = 4096
			vb.cpus = 4
		end
		project.vm.provision "file", source: "./Simple-project-master.rar", destination: "/home/vagrant/Simple-project-master.rar"
		project.vm.provision "file", source: "./update_db.sh", destination: "/home/vagrant/update_db.sh"
		project.vm.provision "file", source: "./update_db.service", destination: "/home/vagrant/update_db.service"
		project.vm.provision "file", source: "./myMonitor.timer", destination: "/home/vagrant/myMonitor.timer"
		project.vm.provision :shell, path: "bootstrap.sh", privileged: false
	end
end