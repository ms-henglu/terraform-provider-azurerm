

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-labschedule-230526085309763344"
  location = "West Europe"
}

resource "azurerm_lab_service_lab" "test" {
  name                = "acctest-lab-23052608530976334"
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
}


resource "azurerm_lab_service_schedule" "test" {
  name       = "acctest-labschedule-230526085309763344"
  lab_id     = azurerm_lab_service_lab.test.id
  notes      = "Testing"
  start_time = "2023-05-26T08:53:09Z"
  stop_time  = "2023-05-26T09:53:09Z"
  time_zone  = "America/Los_Angeles"

  recurrence {
    expiration_date = "2023-05-26T09:53:09Z"
    frequency       = "Weekly"
    interval        = 1
    week_days       = ["Friday", "Thursday"]
  }
}
