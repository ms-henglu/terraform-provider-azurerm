

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-labschedule-240315123309414445"
  location = "West Europe"
}

resource "azurerm_lab_service_lab" "test" {
  name                = "acctest-lab-24031512330941444"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  title               = "Test Title"

  security {
    open_access_enabled = false
  }

  virtual_machine {
    admin_user {
      username = "testadmin"
      password = "Password1234!"
    }

    image_reference {
      offer     = "0001-com-ubuntu-server-focal"
      publisher = "canonical"
      sku       = "20_04-lts"
      version   = "latest"
    }

    sku {
      name     = "Classic_Fsv2_2_4GB_128_S_SSD"
      capacity = 1
    }
  }

  connection_setting {
    client_ssh_access = "Public"
  }
}


resource "azurerm_lab_service_schedule" "test" {
  name      = "acctest-labschedule-240315123309414445"
  lab_id    = azurerm_lab_service_lab.test.id
  stop_time = "2024-03-15T13:33:09Z"
  time_zone = "America/Los_Angeles"
}
