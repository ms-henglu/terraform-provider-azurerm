

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-labschedule-230929065110503857"
  location = "West Europe"
}

resource "azurerm_lab_service_lab" "test" {
  name                = "acctest-lab-23092906511050385"
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
  name       = "acctest-labschedule-230929065110503857"
  lab_id     = azurerm_lab_service_lab.test.id
  notes      = "Testing"
  start_time = "2023-09-29T06:51:10Z"
  stop_time  = "2023-09-29T07:51:10Z"
  time_zone  = "America/Los_Angeles"

  recurrence {
    expiration_date = "2023-09-29T07:51:10Z"
    frequency       = "Weekly"
    interval        = 1
    week_days       = ["Friday", "Thursday"]
  }
}
