

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-labschedule-240315123309418797"
  location = "West Europe"
}

resource "azurerm_lab_service_lab" "test" {
  name                = "acctest-lab-24031512330941879"
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
  name       = "acctest-labschedule-240315123309418797"
  lab_id     = azurerm_lab_service_lab.test.id
  notes      = "Testing"
  start_time = "2024-03-15T12:33:09Z"
  stop_time  = "2024-03-15T13:33:09Z"
  time_zone  = "America/Los_Angeles"

  recurrence {
    expiration_date = "2024-03-15T13:33:09Z"
    frequency       = "Weekly"
    interval        = 1
    week_days       = ["Friday", "Thursday"]
  }
}
