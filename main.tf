provider "null" {}

resource "null_resource" "deploy_puppet" {
  triggers = {
    always = timestamp()
  }

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

  provisioner "remote-exec" {
    # Commands to move the file and restart the Puppet master service
    inline = [
      "sudo cp /tmp/init.pp /etc/puppetlabs/code/environments/production/manifests/init.pp",
      "sudo /opt/puppetlabs/bin/puppet parser validate /etc/puppetlabs/code/environments/production/manifests/init.pp",
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

  
  provisioner "remote-exec" {
    when = destroy 

    # Commands to remove the files and restart the service
    inline = [
      "sudo rm -f /etc/puppetlabs/code/environments/production/manifests/init.pp",
      "sudo rm -f /tmp/init.pp",
      "sudo systemctl restart puppetserver",
      "echo 'Puppet init.pp file removed and server restarted.'"
    ]

    connection {
      type        = "ssh"
      user        = "anushka"
      private_key = file("C:/Users/91739/.ssh/id_rsa")
      host        = "192.168.241.128"
    }
  }
}


resource "null_resource" "deploy_nagios" {
  triggers = {
    always = timestamp()
  }

  # --- Provisioners (Run on Apply) ---
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

  provisioner "remote-exec" {

    inline = [
      "sudo mv /tmp/windows.cfg /usr/local/nagios/etc/servers/windows.cfg",
      "sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg",
      "sudo systemctl restart nagios",
      "sudo systemctl status nagios --no-pager"
    ]

    connection {
      type        = "ssh"
      user        = "anushka"
      private_key = file("C:/Users/91739/.ssh/id_rsa")
      host        = "192.168.241.128"
    }
  }

  
  provisioner "remote-exec" {
    when = destroy # This ensures the commands run when you execute 'terraform destroy'

    # Commands to remove the file and restart the service
    inline = [
      "sudo rm -f /usr/local/nagios/etc/servers/windows.cfg",
      "sudo systemctl restart nagios",
      "echo 'Nagios windows.cfg file removed and server restarted.'"
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