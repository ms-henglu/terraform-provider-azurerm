

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-240311033148467132"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-240311033148467132"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_accelerator" "test" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
}


resource "azurerm_spring_cloud_customized_accelerator" "test" {
  name                        = "acctest-ca-240311033148467132"
  spring_cloud_accelerator_id = azurerm_spring_cloud_accelerator.test.id

  git_repository {
    url                 = "https://github.com/sample-accelerators/fragments.git"
    branch              = "main"
    interval_in_seconds = 100
    path                = "java-version"
  }

  accelerator_tags = ["tag-a", "tag-b"]
  accelerator_type = "Fragment"
  description      = "test description"
  display_name     = "test name"
  icon_url         = "https://images.freecreatives.com/wp-content/uploads/2015/05/smiley-559124_640.jpg"
}
