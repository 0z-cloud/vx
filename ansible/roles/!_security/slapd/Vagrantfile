Vagrant.configure("2") do |config|
  config.vm.define :slapd do |slapd|
    slapd.vm.hostname = "shannontest"
	  slapd.vm.box = "ubuntu/trusty64"
    slapd.vm.network :private_network, ip: "192.168.10.44"
    slapd.vm.provision "ansible" do |ansible|
      ansible.sudo = true
      ansible.verbose = "vv"
      ansible.playbook = "test.yml"
    end
  end
end
