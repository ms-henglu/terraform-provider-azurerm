


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-labschedule-231013043648650064"
  location = "West Europe"
}

resource "azurerm_lab_service_lab" "test" {
  name                = "acctest-lab-23101304364865006"
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
  name      = "acctest-labschedule-231013043648650064"
  lab_id    = azurerm_lab_service_lab.test.id
  stop_time = "2023-10-13T05:36:48Z"
  time_zone = "America/Los_Angeles"
}


resource "azurerm_lab_service_schedule" "import" {
  name      = azurerm_lab_service_schedule.test.name
  lab_id    = azurerm_lab_service_schedule.test.lab_id
  stop_time = azurerm_lab_service_schedule.test.stop_time
  time_zone = azurerm_lab_service_schedule.test.time_zone
}
