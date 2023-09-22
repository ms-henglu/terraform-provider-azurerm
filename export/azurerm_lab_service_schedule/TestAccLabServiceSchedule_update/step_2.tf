

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-labschedule-230922061327788609"
  location = "West Europe"
}

resource "azurerm_lab_service_lab" "test" {
  name                = "acctest-lab-23092206132778860"
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
  name       = "acctest-labschedule-230922061327788609"
  lab_id     = azurerm_lab_service_lab.test.id
  notes      = "Testing2"
  start_time = "2023-09-22T07:13:27Z"
  stop_time  = "2023-09-22T08:13:27Z"
  time_zone  = "America/Grenada"

  recurrence {
    expiration_date = "2023-09-22T08:13:27Z"
    frequency       = "Daily"
    interval        = 2
  }
}
