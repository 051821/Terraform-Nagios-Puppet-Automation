provider "null" {}

############################################################
# 1. DEPLOY PUPPET MODULE (init.pp) + GLOBAL site.pp
############################################################

resource "null_resource" "deploy_puppet" {
  triggers = {
    always = timestamp()
  }

  # --------------------- Upload init.pp ---------------------
  provisioner "file" {
    source      = "puppet-manifests/init.pp"
    destination = "/tmp/init.pp"

    connection {
      type        = "ssh"
      user        = "anushka"
      private_key = file("C:/Users/91739/.ssh/id_rsa")
      host        = "192.168.241.128"
    }
  }

  # --------------------- Upload site.pp ---------------------
  provisioner "file" {
    source      = "puppet-manifests/site.pp"
    destination = "/tmp/site.pp"

    connection {
      type        = "ssh"
      user        = "anushka"
      private_key = file("C:/Users/91739/.ssh/id_rsa")
      host        = "192.168.241.128"
    }
  }

  # ---------------- Setup Puppet module + manifest ----------------
  provisioner "remote-exec" {
    inline = [

      # Create module directory
      "sudo mkdir -p /etc/puppetlabs/code/environments/production/modules/project1/manifests",

      # Move init.pp → module path
      "sudo mv /tmp/init.pp /etc/puppetlabs/code/environments/production/modules/project1/manifests/init.pp",

      # Move site.pp → global path
      "sudo mv /tmp/site.pp /etc/puppetlabs/code/environments/production/manifests/site.pp",

      # Validate init.pp
      "sudo /opt/puppetlabs/bin/puppet parser validate /etc/puppetlabs/code/environments/production/modules/project1/manifests/init.pp",

      # Validate site.pp
      "sudo /opt/puppetlabs/bin/puppet parser validate /etc/puppetlabs/code/environments/production/manifests/site.pp",

      # Restart puppetserver
      "sudo systemctl restart puppetserver",
      "sleep 5"
    ]

    connection {
      type        = "ssh"
      user        = "anushka"
      private_key = file("C:/Users/91739/.ssh/id_rsa")
      host        = "192.168.241.128"
    }
  }

  # ------------------- CLEANUP ON DESTROY -------------------
  provisioner "remote-exec" {
    when = destroy

    inline = [
      "sudo rm -rf /etc/puppetlabs/code/environments/production/modules/project1",
      "sudo rm -f /etc/puppetlabs/code/environments/production/manifests/site.pp",
      "sudo systemctl restart puppetserver",
      "echo 'Puppet module and site.pp removed successfully.'"
    ]

    connection {
      type        = "ssh"
      user        = "anushka"
      private_key = file("C:/Users/91739/.ssh/id_rsa")
      host        = "192.168.241.128"
    }
  }
}



############################################################
# 2. DEPLOY NAGIOS OBJECT CONFIG (windows.cfg)
############################################################

resource "null_resource" "deploy_nagios" {
  triggers = {
    always = timestamp()
  }

  # Upload cfg file
  provisioner "file" {
    source      = "nagios/windows.cfg"
    destination = "/tmp/windows.cfg"

    connection {
      type        = "ssh"
      user        = "anushka"
      private_key = file("C:/Users/91739/.ssh/id_rsa")
      host        = "192.168.241.128"
    }
  }

  # Place cfg inside /objects/ and update nagios.cfg
  provisioner "remote-exec" {
    inline = [

      # Move cfg → Nagios objects directory
      "sudo mv /tmp/windows.cfg /usr/local/nagios/etc/objects/windows.cfg",

      # Add cfg_file entry (avoid duplication)
      "grep -qxF 'cfg_file=/usr/local/nagios/etc/objects/windows.cfg' /usr/local/nagios/etc/nagios.cfg || echo 'cfg_file=/usr/local/nagios/etc/objects/windows.cfg' | sudo tee -a /usr/local/nagios/etc/nagios.cfg",

      # Validate Nagios configuration
      "sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg",

      # Restart Nagios
      "sudo systemctl restart nagios"
    ]

    connection {
      type        = "ssh"
      user        = "anushka"
      private_key = file("C:/Users/91739/.ssh/id_rsa")
      host        = "192.168.241.128"
    }
  }

  # ------------------- DESTROY CLEANUP -------------------
  provisioner "remote-exec" {
    when = destroy

    inline = [
      # Remove cfg
      "sudo rm -f /usr/local/nagios/etc/objects/windows.cfg",

      # Remove line from nagios.cfg
      "sudo sed -i '/cfg_file=\\/usr\\/local\\/nagios\\/etc\\/objects\\/windows.cfg/d' /usr/local/nagios/etc/nagios.cfg",

      "sudo systemctl restart nagios",
      "echo 'Nagios config removed successfully.'"
    ]

    connection {
      type        = "ssh"
      user        = "anushka"
      private_key = file("C:/Users/91739/.ssh/id_rsa")
      host        = "192.168.241.128"
    }
  }

  depends_on = [null_resource.deploy_puppet]
}
