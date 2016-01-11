# -*- mode: ruby -*-
# vi: set ft=ruby :


# Method to convert .img or .img.zip to .vdi so it can be attached to the VM.
def get_vdi_from_img(src)

    res = src

    fdir = File.dirname src

    if src.end_with? ".zip"

        vdi_file = src.gsub(/(.img)?.zip/, '') + ".vdi"
        img_file = src.gsub(/(.img)?.zip/, '') + ".img"

        if File.exist?(vdi_file)
            res = vdi_file
        elsif File.exist?(img_file)
            src = img_file
        else
            system "unzip -o -d #{fdir} #{src}"
            if File.exist?(img_file)
                src = img_file
            else
                abort("ERROR: Could not extract RPI_IMG.")
            end
        end
    end

    ext = File.extname(src)
    fname = File.basename src, ext
    img_file = File.join(fdir,"#{fname}.img")
    vdi_file = File.join(fdir,"#{fname}.vdi")

    if ext == ".img"
      if File.exist?(vdi_file)
        res = vdi_file
      else
        puts "Converting IMG to VDI: #{src}"
        system "VBoxManage convertfromraw --format VDI #{src} #{vdi_file}"
        abort "ERROR: Could not convert img to vdi" unless $? == 0
        res = vdi_file
      end
    end

    return res
end

################################

Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise64"

  abort "ERROR: environent variable OS_NAME not defined" unless ENV["OS_NAME"]
  os_name = ENV["OS_NAME"]

  # Attach RPI disk image to VM. Provied by ENV var RPI_IMG
  abort "ERROR: environent variable RPI_IMG not defined" unless ENV["RPI_IMG"]

  rpi_img = File.realpath(ENV["RPI_IMG"])

  abort "ERROR: RPI_IMG not found: #{src}" unless File.exist?(rpi_img)

  file_to_disk = get_vdi_from_img(rpi_img)

  config.vm.provider "virtualbox" do |vm|
    vm.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
  end

  config.vm.provision "shell", inline: <<-SHELL
     /vagrant/make_tar_xz.sh /dev/sdb1 /dev/sdb2 /vagrant/os/#{os_name}/
  SHELL

end
