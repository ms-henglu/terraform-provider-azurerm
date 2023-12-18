package containers_test

// NOTE: this file is generated - manual changes will be overwritten.
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See NOTICE.txt in the project root for license information.
import (
	"context"
	"fmt"
	"testing"

	"github.com/hashicorp/go-azure-sdk/resource-manager/containerservice/2023-10-15/fleetupdatestrategies"
	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance"
	"github.com/hashicorp/terraform-provider-azurerm/internal/acceptance/check"
	"github.com/hashicorp/terraform-provider-azurerm/internal/clients"
	"github.com/hashicorp/terraform-provider-azurerm/internal/tf/pluginsdk"
	"github.com/hashicorp/terraform-provider-azurerm/utils"
)

type KubernetesFleetUpdateStrategyTestResource struct{}

func TestAccKubernetesFleetUpdateStrategy_basic(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_kubernetes_fleet_update_strategy", "test")
	r := KubernetesFleetUpdateStrategyTestResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccKubernetesFleetUpdateStrategy_requiresImport(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_kubernetes_fleet_update_strategy", "test")
	r := KubernetesFleetUpdateStrategyTestResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.RequiresImportErrorStep(r.requiresImport),
	})
}

func TestAccKubernetesFleetUpdateStrategy_complete(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_kubernetes_fleet_update_strategy", "test")
	r := KubernetesFleetUpdateStrategyTestResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}

func TestAccKubernetesFleetUpdateStrategy_update(t *testing.T) {
	data := acceptance.BuildTestData(t, "azurerm_kubernetes_fleet_update_strategy", "test")
	r := KubernetesFleetUpdateStrategyTestResource{}

	data.ResourceTest(t, r, []acceptance.TestStep{
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.complete(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
		{
			Config: r.basic(data),
			Check: acceptance.ComposeTestCheckFunc(
				check.That(data.ResourceName).ExistsInAzure(r),
			),
		},
		data.ImportStep(),
	})
}
func (r KubernetesFleetUpdateStrategyTestResource) Exists(ctx context.Context, clients *clients.Client, state *pluginsdk.InstanceState) (*bool, error) {
	id, err := fleetupdatestrategies.ParseUpdateStrategyID(state.ID)
	if err != nil {
		return nil, err
	}

	resp, err := clients.ContainerService.V20231015.FleetUpdateStrategies.Get(ctx, *id)
	if err != nil {
		return nil, fmt.Errorf("reading %s: %+v", *id, err)
	}

	return utils.Bool(resp.Model != nil), nil
}
func (r KubernetesFleetUpdateStrategyTestResource) basic(data acceptance.TestData) string {
	return fmt.Sprintf(`
%s

provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_fleet_update_strategy" "test" {
  fleet_id = azurerm_kubernetes_fleet_manager.test.id
  name     = "acctestkfus-${var.random_string}"
  strategy {
    stage {
      name = "acctestkfus-${var.random_string}"
      group {
        name = "acctestkfus-${var.random_string}"
      }
    }
  }
}
`, r.template(data))
}

func (r KubernetesFleetUpdateStrategyTestResource) requiresImport(data acceptance.TestData) string {
	return fmt.Sprintf(`
%s

resource "azurerm_kubernetes_fleet_update_strategy" "import" {
  fleet_id = azurerm_kubernetes_fleet_update_strategy.test.fleet_id
  name     = azurerm_kubernetes_fleet_update_strategy.test.name
  strategy {
    stage = azurerm_kubernetes_fleet_update_strategy.test.strategy.0.stage
  }
}
`, r.basic(data))
}

func (r KubernetesFleetUpdateStrategyTestResource) complete(data acceptance.TestData) string {
	return fmt.Sprintf(`
%s

provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_fleet_update_strategy" "test" {
  fleet_id = azurerm_kubernetes_fleet_manager.test.id
  name     = "acctestkfus-${var.random_string}"
  strategy {
    stage {
      name = "acctestkfus-${var.random_string}"
      group {
        name = "acctestkfus-${var.random_string}"
      }
      after_stage_wait_in_seconds = 21
    }
  }
}
`, r.template(data))
}

func (r KubernetesFleetUpdateStrategyTestResource) template(data acceptance.TestData) string {
	return fmt.Sprintf(`
variable "primary_location" {
  default = %q
}
variable "random_integer" {
  default = %d
}
variable "random_string" {
  default = %q
}

resource "azurerm_kubernetes_fleet_manager" "test" {
  name                = "acctestkfm${var.random_string}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  hub_profile {
    dns_prefix = "val-${var.random_string}"
  }
}


resource "azurerm_resource_group" "test" {
  name     = "acctestrg-${var.random_integer}"
  location = var.primary_location
}
`, data.Locations.Primary, data.RandomInteger, data.RandomString)
}
