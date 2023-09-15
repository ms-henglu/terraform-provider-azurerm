
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023625643138"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestvn-230915023625643138"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  address_space       = ["10.0.0.0/8"]
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsn-230915023625643138"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_storage_account" "test" {
  name                     = "accsa230915023625643138"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "acctestsc-230915023625643138"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-230915023625643138"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allocation_method   = "Static"
}

resource "azurerm_lb" "test" {
  name                = "acctestlb-230915023625643138"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  frontend_ip_configuration {
    name                 = "ip-address"
    public_ip_address_id = azurerm_public_ip.test.id
  }
}

resource "azurerm_lb_backend_address_pool" "test" {
  name            = "acctestbap-230915023625643138"
  loadbalancer_id = azurerm_lb.test.id
}

resource "azurerm_virtual_machine_scale_set" "test" {
  name                = "acctestvmss-230915023625643138"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  upgrade_policy_mode = "Automatic"

  sku {
    name     = "Standard_F2"
    tier     = "Standard"
    capacity = "1"
  }

  os_profile {
    computer_name_prefix = "prefix"
    admin_username       = "ubuntu"
    custom_data          = "updated custom data!"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvXYZAjVUt2aojUV3XIA+PY6gXrgbvktXwf2NoIHGlQFhogpMEyOfqgogCtTBM7MNCS3ELul6SV+mlpH08Ki45ADIQuDXdommCvsMFW096JrsHOJpGfjCsJ1gbbv7brB3Ag+BSGb4qO3pRsEVTtZCeJDwfH5D7vmqP5xXcELKR4UAtKQKUhLvt6mhW90sFLTJeOTiYGbavIKqfCUFSeSMQkUPr8o3uzOfeWyCw7tc7szLuvfwJ5poGHuve73KKAlUnDTPUrhyj7iITZSDl+/i+bpDzPyCyJWDMsC0ON7q2fDr2mEz0L9ACrsI5Nx3lt5fe+IaHSrjivqnL8SqUWSN45o9Qp99sGWFiuTfos8f1jp+AXzC4ArVtKyRg/CnzKRiK0CGSxBJ5s9zAoa7yBBmjCszq89vFa0eMgpEIZFwa6kKJKt9AfRBXgO9YGPV4uaN7topy92/p2pE+vF8IafarbvnTDOQt62mS07tXYqYg1DhecrmBVWKlq9oafBweoeTjoq52SoGsuDc/YAOzIgWVIuvV8yKoh9KbXPWowjLtxDhRIS/d1nMMNdNI8X0TQivgi5+umMgAXhsVAKSNDUauLt4jimYkWAuE+R6KoCqVFdaB9bQDySBjAziruDSe3reToydjzzluvHMjWK8QiDynxs41pi4zZz6gAlca3QPkEQ== hello@world.com"
    }
  }

  network_profile {
    name    = "TestNetworkProfile"
    primary = true

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.test.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.test.id]
    }
  }

  storage_profile_os_disk {
    name           = "osDiskProfile"
    caching        = "ReadWrite"
    create_option  = "FromImage"
    os_type        = "linux"
    vhd_containers = ["${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}"]
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
