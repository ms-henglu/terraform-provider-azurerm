

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-lab-231013043648650139"
  location = "West Europe"
}


resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig231013043648650139"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg231013043648650139"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"
  specialized         = true

  identifier {
    publisher = "AccTesPublisher231013043648650139"
    offer     = "AccTesOffer231013043648650139"
    sku       = "AccTesSku231013043648650139"
  }
}

data "azuread_service_principal" "test" {
  application_id = "c7bb12bf-0b39-4f7f-9171-f418ff39b76a"
}

resource "azurerm_role_assignment" "test" {
  scope                = azurerm_shared_image_gallery.test.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_service_principal.test.object_id
}

locals {
  first_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+wWK73dCr+jgQOAxNsHAnNNNMEMWOHYEccp6wJm2gotpr9katuF/ZAdou5AaW1C61slRkHRkpRRX9FA9CYBiitZgvCCz+3nWNN7l/Up54Zps/pHWGZLHNJZRYyAB6j5yVLMVHIHriY49d/GZTZVNB8GoJv9Gakwc/fuEZYYl4YDFiGMBP///TzlI4jhiJzjKnEvqPFki5p2ZRJqcbCiF4pJrxUQR/RXqVFQdbRLZgYfJ8xGB878RENq3yQ39d8dVOkq4edbkzwcUmwwwkYVPIoDGsYLaRHnG+To7FvMeyO7xDVQkMKzopTQV8AuKpyvpqu0a9pWOMaiCyDytO7GGN you@me.com"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-vnet-231013043648650139"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctest-sn-231013043648650139"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "Microsoft.LabServices.labplans"

    service_delegation {
      name = "Microsoft.LabServices/labplans"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231013043648650139"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "test" {
  name                = "acctestVM-linux-231013043648650139"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_F2"
  admin_username      = "adminuser"

  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = local.first_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_shared_image_version" "test" {
  name                = "0.0.1"
  gallery_name        = azurerm_shared_image_gallery.test.name
  image_name          = azurerm_shared_image.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  managed_image_id    = azurerm_linux_virtual_machine.test.id

  target_region {
    name                   = azurerm_resource_group.test.location
    regional_replica_count = 1
  }
}

resource "azurerm_lab_service_plan" "test" {
  name                = "acctest-lslp-231013043648650139"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  allowed_regions     = [azurerm_resource_group.test.location]
  shared_gallery_id   = azurerm_shared_image_gallery.test.id

  depends_on = [azurerm_role_assignment.test, azurerm_shared_image_version.test]
}

resource "azurerm_lab_service_lab" "test" {
  name                = "acctest-lab-231013043648650139"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  title               = "Test Title2"
  description         = "Test Description2"
  lab_plan_id         = azurerm_lab_service_plan.test.id

  security {
    open_access_enabled = true
  }

  virtual_machine {
    usage_quota                                 = "PT11H"
    additional_capability_gpu_drivers_installed = false
    create_option                               = "TemplateVM"
    shared_password_enabled                     = true

    admin_user {
      username = "testadmin"
      password = "Password1234!"
    }

    image_reference {
      id = azurerm_shared_image.test.id
    }

    sku {
      name     = "Classic_Fsv2_2_4GB_128_S_SSD"
      capacity = 0
    }
  }

  auto_shutdown {
    disconnect_delay = "PT16M"
    idle_delay       = "PT16M"
    no_connect_delay = "PT16M"
    shutdown_on_idle = "LowUsage"
  }

  connection_setting {
    client_rdp_access = "Public"
  }

  tags = {
    Env = "Test2"
  }
}
