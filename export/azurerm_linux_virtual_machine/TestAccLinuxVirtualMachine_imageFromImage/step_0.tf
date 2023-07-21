

# note: whilst these aren't used in all tests, it saves us redefining these everywhere
locals {
  first_public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9ddAwoR0XBoT9kixLX6atgX9dovt9fpR1HO/R9jYwYnuB+SZ845KSqat+U0m6oagZhpsfcEEwjGGjQz6Z1rB6mvffsKq6i74cmm0jO564nBnZQeh31q3sFNs+XdrDtFmnYRqdPHhhr1sw0C/rxbiaE6nYZWRfHW//81nEePKMpjiN8JsrYQNbzEpz8QOBSquwBmXO+LVx//zAbY4jGTa4hjGeNzIgMJZ8Jk/11XbcxSK1PK43BrejHg6kctmEkYvMH/o12RfAeB8okGCRW3scwOozxVrHwxaPgEf03jig+Ag9V+GXNBabL5AWtxcuPN63rUfaAXEIXTHmndwVOxlpLrUf5ox1+ddGyWbLMXzd7akPioof5MNJMq/yuFGC5dY0Z6/+yGRNtShQesVo/czhKEPGIcsIi5gnKdfDB4i9ay2yz8ystnW6jbabcyqejk1Qc61wapaFdhUHL0iD/GW/5ZujDs5C3BT7EIgKLIfAaAx5TBEJyE1KQ/GEOifB8ztDl/gp99o+i2HKABtmYv12y4JVlEUkRckeLrw6luEb3ColHshsQcQGfudGFFgdEdcgBrV4Ch7IkLxVYQl3pegzZiirMPnRKh10r/Hrg6uYxn7sLeTJoD5VOKmqmeK4kFXsZMVtA6/SnxQtUKkKlfLBwBSDrrdgLjBV+KOndiwC7Q=="
  second_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0/NDMj2wG6bSa6jbn6E3LYlUsYiWMp1CQ2sGAijPALW6OrSu30lz7nKpoh8Qdw7/A4nAJgweI5Oiiw5/BOaGENM70Go+VM8LQMSxJ4S7/8MIJEZQp5HcJZ7XDTcEwruknrd8mllEfGyFzPvJOx6QAQocFhXBW6+AlhM3gn/dvV5vdrO8ihjET2GoDUqXPYC57ZuY+/Fz6W3KV8V97BvNUhpY5yQrP5VpnyvvXNFQtzDfClTvZFPuoHQi3/KYPi6O0FSD74vo8JOBZZY09boInPejkm9fvHQqfh0bnN7B6XJoUwC1Qprrx+XIy7ust5AEn5XL7d4lOvcR14MxDDKEp you@me.com"
  vm_name           = "acctestsourcevm-230721014716488384"
  admin_username    = "testadmin230721014716488384"
  admin_password    = "Password1234!230721014716488384"
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230721014716488384"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-230721014716488384"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctpip-230721014716488384"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  allocation_method   = "Static"
  domain_name_label   = local.vm_name
}

resource "azurerm_network_interface" "public" {
  name                = "acctnicsource-230721014716488384"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  ip_configuration {
    name                          = "testconfigurationsource"
    subnet_id                     = "${azurerm_subnet.test.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.test.id}"
  }
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-230721014716488384"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230721014716488384"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
}


resource "azurerm_linux_virtual_machine" "source" {
  name                            = "acctestsourceVM-230721014716488384"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = local.admin_username
  disable_password_authentication = false
  admin_password                  = local.admin_password

  network_interface_ids = [
    azurerm_network_interface.public.id,
  ]

  admin_ssh_key {
    username   = local.admin_username
    public_key = local.first_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
