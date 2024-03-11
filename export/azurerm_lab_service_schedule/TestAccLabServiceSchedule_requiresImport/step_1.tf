


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-labschedule-240311032341828282"
  location = "West Europe"
}

resource "azurerm_lab_service_lab" "test" {
  name                = "acctest-lab-24031103234182828"
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
  name      = "acctest-labschedule-240311032341828282"
  lab_id    = azurerm_lab_service_lab.test.id
  stop_time = "2024-03-11T04:23:41Z"
  time_zone = "America/Los_Angeles"
}


resource "azurerm_lab_service_schedule" "import" {
  name      = azurerm_lab_service_schedule.test.name
  lab_id    = azurerm_lab_service_schedule.test.lab_id
  stop_time = azurerm_lab_service_schedule.test.stop_time
  time_zone = azurerm_lab_service_schedule.test.time_zone
}
