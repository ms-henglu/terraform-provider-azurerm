


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-labuser-230203063544560408"
  location = "West Europe"
}

resource "azurerm_lab_service_lab" "test" {
  name                = "acctest-lab-23020306354456040"
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


resource "azurerm_lab_service_user" "test" {
  name   = "acctest-labuser-230203063544560408"
  lab_id = azurerm_lab_service_lab.test.id
  email  = "terraform-acctest@hashicorp.com"
}


resource "azurerm_lab_service_user" "import" {
  name   = azurerm_lab_service_user.test.name
  lab_id = azurerm_lab_service_user.test.lab_id
  email  = azurerm_lab_service_user.test.email
}
