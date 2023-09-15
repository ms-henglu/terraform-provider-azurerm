
provider "azurerm" {
  features {}
}



resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915022839963404"
  location = "West Europe"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230915022839963404"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Windows"
  sku_name            = "S1"

}


resource "azurerm_windows_web_app" "test" {
  name                = "acctestWA-230915022839963404"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  site_config {
    virtual_application {
      virtual_path  = "/"
      physical_path = "site\\wwwroot"
      preload       = true

      virtual_directory {
        virtual_path  = "/stuff"
        physical_path = "site\\stuff"
      }
    }

    virtual_application {
      virtual_path  = "/static-content"
      physical_path = "site\\static"
      preload       = true

      virtual_directory {
        virtual_path  = "/images"
        physical_path = "site\\static\\images"
      }

      virtual_directory {
        virtual_path  = "/css"
        physical_path = "site\\static\\css"
      }
    }
  }
}
