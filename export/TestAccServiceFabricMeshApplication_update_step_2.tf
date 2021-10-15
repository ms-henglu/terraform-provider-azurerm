
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-sfm-211015014830461132"
  location = "West Europe"
}

resource "azurerm_service_fabric_mesh_application" "test" {
  name                = "accTest-211015014830461132"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  service {
    name    = "testservice1"
    os_type = "Linux"

    code_package {
      name       = "testcodepackage1"
      image_name = "seabreeze/sbz-helloworld:1.0-alpine"

      resources {
        requests {
          memory = 1
          cpu    = 1
        }
      }
    }
  }

  service {
    name    = "testservice2"
    os_type = "Linux"

    code_package {
      name       = "testcodepackage2"
      image_name = "seabreeze/sbz-helloworld:1.0-alpine"

      resources {
        requests {
          memory = 2
          cpu    = 2
        }
      }
    }
  }

  tags = {
    Hello = "World"
  }
}
