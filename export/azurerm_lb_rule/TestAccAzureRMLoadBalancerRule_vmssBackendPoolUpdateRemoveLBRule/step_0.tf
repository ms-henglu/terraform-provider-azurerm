


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lb-230825024753491587"
  location = "West Europe"
}

resource "azurerm_public_ip" "test" {
  name                = "test-ip-230825024753491587"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "test" {
  name                = "arm-test-loadbalancer-230825024753491587"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "one-230825024753491587"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}


resource "azurerm_lb_backend_address_pool" "test" {
  name            = "acctest-lb-BAP-230825024753491587"
  loadbalancer_id = azurerm_lb.test.id
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-lb-vnet-230825024753491587"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-lb-subnet-230825024753491587"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "test" {
  name                = "acctest-lb-vmss-230825024753491587"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"
  admin_password      = "P@ssword1234!"

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.test.id
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.test.id
      ]
    }
  }
}


resource "azurerm_lb_rule" "test" {
  loadbalancer_id                = azurerm_lb.test.id
  name                           = "LbRule-v8cbw"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.test.id]
  frontend_ip_configuration_name = azurerm_lb.test.frontend_ip_configuration.0.name
}
