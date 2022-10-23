resource "azurerm_resource_group" "elite_general_resources" {
  name     = local.elite_general_resources
  location = var.location
}

resource "azurerm_network_interface" "labnic" {
  name                = join("-", [local.server, "lab", "nic"])
  location            = local.buildregion
  resource_group_name = azurerm_resource_group.elite_general_resources.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.application_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.labpip.id
  }
}

resource "azurerm_public_ip" "labpip" {
  name                = join("-", [local.server, "lab", "pip"])
  resource_group_name = azurerm_resource_group.elite_general_resources.name
  location            = local.buildregion
  allocation_method   = "Static"

  tags = local.common_tags
}


resource "azurerm_linux_virtual_machine" "Linuxvm" {
  name                = join("-", [local.server, "linux", "vm"])
  resource_group_name = azurerm_resource_group.elite_general_resources.name
  location            = local.buildregion
  size                = "Standard_DS1"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.labnic.id,
  ]

  connection {
    type        = "ssh"
    user        = var.user
    private_key = file(var.path_privatekey)
    host        = self.public_ip_address
  }

  admin_ssh_key {
    username   = "adminuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDR0m8lkht5iFlNhMBrdGmAuipiysi0D2fwG68h6JNEHR+lf0+MYorC/2l/65kN4zHXBQ2TX1QUE9Z0IJPHdYloXJAyFQTKNhPGXlFb98udcdBoxfGMWoKJWjnef/LKvfT5bixgXObi6WZQyt2zBD51w7Gz3y4bM04kOEUaMu9QyaVQfrqSeln2CmcRdXnl599o+8CxmewMBNDlb2jLsTyIFeRBhZRG+AYIuqCE/8vbp9L9owW8oUS5jyI6cfB6YUXXGZuodE9e2qzASzqNgi6LHTrB1BUGFlVqnMXPnCY5lUqr2fKpx1ZZfXptSMFBAvdM41RLJpdkEQqwzCe30uGZ1vQEReic+80dsAH2acVx53xtyIJKAeIDPb5ms6vsSU9OIBIpssvEvfTdOaICQ74ZxxE9LseV/W3eZrwhLouua87zvmn6zwYLsVwrEu6wtL3bjIFEYhVIdjZB6aVP60X1KdzE4Ihs/16zxRAXrBLdNEFf09eyysdO9b8E2wAA5V8= apple@Tamie-Emmanuel"
  }
  # provisioner "file" {
  #   source      = "./scripts/keyrevive.sh"
  #   destination = "/tmp/keyrevive.sh"
  # }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.user} -i '${self.public_ip_address},' --private-key ${var.path_privatekey} ansibleplaybooks/nginx.yml -vv"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "Canonical"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}