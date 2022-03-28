---
subcategory: "Spring Cloud"
layout: "azurerm"
page_title: "Azure Resource Manager: azurerm_spring_cloud_api_portal"
description: |-
  Manages a Spring Cloud API Portal.
---

# azurerm_spring_cloud_api_portal

Manages a Spring Cloud API Portal.

## Example Usage

```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "West Europe"
}

resource "azurerm_spring_cloud_service" "example" {
  name                = "example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "E0"
}

resource "azurerm_spring_cloud_gateway" "example" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.example.id
}

resource "azurerm_spring_cloud_api_portal" "example" {
  name                    = "default"
  spring_cloud_service_id = azurerm_spring_cloud_service.example.id
  gateway_ids             = [azurerm_spring_cloud_gateway.example.id]
  https_only              = false
  public                  = true
  instance_count          = 2
}
```

## Arguments Reference

The following arguments are supported:

* `name` - (Required) The name which should be used for this Spring Cloud API Portal. Changing this forces a new Spring Cloud API Portal to be created.

* `spring_cloud_service_id` - (Required) The ID of the Spring Cloud Service. Changing this forces a new Spring Cloud API Portal to be created.

---

* `gateway_ids` - (Optional) Specifies a list of Spring Cloud Gateway IDs.

* `https_only` - (Optional) Indicate if only https is allowed.

* `instance_count` - (Optional) Specifies the required instance count of the Spring Cloud API Portal. Possible Values are between `1` and `500`. Defaults to `1` if not specified.

* `public` - (Optional) Indicates whether the API portal exposes endpoint.

* `source_urls` - (Optional) Specifies a list of OpenAPI source URL locations.

* `sso_properties` - (Optional) A `sso_properties` block as defined below.

---

A `sso_properties` block supports the following:

* `client_id` - (Optional) The public identifier for the application.

* `client_secret` - (Optional) The secret known only to the application and the authorization server.

* `issuer_uri` - (Optional) The URI of Issuer Identifier.

* `scope` - (Optional) It defines the specific actions applications can be allowed to do on a user's behalf.

## Attributes Reference

In addition to the Arguments listed above - the following Attributes are exported: 

* `id` - The ID of the Spring Cloud API Portal.

* `url` - URL of the API portal, exposed when `public` is true.

## Timeouts

The `timeouts` block allows you to specify [timeouts](https://www.terraform.io/docs/configuration/resources.html#timeouts) for certain actions:

* `create` - (Defaults to 30 minutes) Used when creating the Spring Cloud API Portal.
* `read` - (Defaults to 5 minutes) Used when retrieving the Spring Cloud API Portal.
* `update` - (Defaults to 30 minutes) Used when updating the Spring Cloud API Portal.
* `delete` - (Defaults to 30 minutes) Used when deleting the Spring Cloud API Portal.

## Import

Spring Cloud API Portals can be imported using the `resource id`, e.g.

```shell
terraform import azurerm_spring_cloud_api_portal.example /subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/resourceGroup1/providers/Microsoft.AppPlatform/Spring/service1/apiPortals/apiPortal1
```
