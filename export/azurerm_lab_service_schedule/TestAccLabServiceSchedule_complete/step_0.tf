

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-labschedule-240311032341826868"
  location = "West Europe"
}

resource "azurerm_lab_service_lab" "test" {
  name                = "acctest-lab-24031103234182686"
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
  name       = "acctest-labschedule-240311032341826868"
  lab_id     = azurerm_lab_service_lab.test.id
  notes      = "Testing"
  start_time = "2024-03-11T03:23:41Z"
  stop_time  = "2024-03-11T04:23:41Z"
  time_zone  = "America/Los_Angeles"

  recurrence {
    expiration_date = "2024-03-11T04:23:41Z"
    frequency       = "Weekly"
    interval        = 1
    week_days       = ["Friday", "Thursday"]
  }
}
