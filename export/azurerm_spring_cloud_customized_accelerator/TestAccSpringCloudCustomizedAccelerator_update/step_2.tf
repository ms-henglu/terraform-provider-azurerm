

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-231016034754051694"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-231016034754051694"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_accelerator" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}


resource "azurerm_spring_cloud_customized_accelerator" "test" {
  name                        = "acctest-ca-231016034754051694"
  spring_cloud_accelerator_id = azurerm_spring_cloud_accelerator.test.id

  git_repository {
    url                 = "https://github.com/Azure-Samples/piggymetrics"
    branch              = "Azure"
    interval_in_seconds = 100
  }

  accelerator_tags = ["tag-a", "tag-b"]
  description      = "test description"
  display_name     = "test name"
  icon_url         = "https://images.freecreatives.com/wp-content/uploads/2015/05/smiley-559124_640.jpg"
}
