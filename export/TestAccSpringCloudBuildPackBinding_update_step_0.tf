

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-spring-220715004924378579"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "test" {
  name                = "acctest-sc-220715004924378579"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_builder" "test" {
  name                    = "acc-ske4k"
  spring_cloud_service_id = azurerm_spring_cloud_service.test.id
  build_pack_group {
    name           = "mix"
    build_pack_ids = ["tanzu-buildpacks/java-azure"]
  }

  stack {
    id      = "io.buildpacks.stacks.bionic"
    version = "base"
  }
}


resource "azurerm_spring_cloud_build_pack_binding" "test" {
  name                    = "acc-u3o0z"
  spring_cloud_builder_id = azurerm_spring_cloud_builder.test.id
  binding_type            = "ApplicationInsights"
}
