package provider

import (
	"context"
	"fmt"
	"github.com/Azure/azure-sdk-for-go/services/preview/network/mgmt/2021-02-01-preview/network"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/location"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/utils"
	"testing"

	"github.com/Azure/azure-sdk-for-go/services/resources/mgmt/2016-02-01/resources"
	"github.com/hashicorp/go-azure-helpers/authentication"
	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/internal/clients"
)

func getClient() (interface{}, error) {
	builder := &authentication.Builder{
		SubscriptionID: "67a9759d-d099-4aa8-8675-e6cfd669c3f4",
		ClientID:       "e03ef952-1a30-4665-a918-ad32cdba50e1",
		ClientSecret:   "Y--FC7QHYfE~~1SQXdiVm9dOq7bZC9u82A",
		TenantID:       "72f988bf-86f1-41af-91ab-2d7cd011db47",
		TenantOnly:     false,

		AuxiliaryTenantIDs: nil,
		Environment:        "public",
		MetadataHost:       "",
		MsiEndpoint:        "",
		ClientCertPassword: "",
		ClientCertPath:     "",

		//FeatureToggles
		SupportsClientCertAuth:         true,
		SupportsClientSecretAuth:       true,
		SupportsManagedServiceIdentity: false,
		SupportsAzureCliToken:          true,
		SupportsAuxiliaryTenants:       false,

		//DocLinks
		ClientSecretDocsLink: "https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret",
	}

	config, err := builder.Build()
	if err != nil {
		return nil, fmt.Errorf("ErrorbuildingAzureRMClient:%s", err)
	}

	clientBuilder := clients.ClientBuilder{
		AuthConfig:               config,
		SkipProviderRegistration: false,
		TerraformVersion:         "0.11+compatible",
		//PartnerId:"",
		DisableCorrelationRequestID: false,
		DisableTerraformPartnerID:   false,
		//Features:expandFeatures(d.Get("features").([]interface{})),
		StorageUseAzureAD: false,

		//thisfieldisintentionallynotexposedintheproviderblock,sinceit'sonlyusedfor
		//platformleveltracing
		CustomCorrelationRequestID: "",
	}

	client, err := clients.Build(context.Background(), clientBuilder)
	if err != nil {
		return nil, err
	}
	return client,
		nil
}

func TestClient2(t *testing.T) {
	client, err := getClient()
	if err != nil {
		fmt.Errorf("%v", err)
	}
	providersClient := client.(*clients.Client).Resource.ProvidersClient
	provider, err := providersClient.Get(context.Background(), "Microsoft.Network", "")
	if err != nil {
		fmt.Errorf("%v", err)
	}
	resourceType := resources.ProviderResourceType{}
	for _, p := range *provider.ResourceTypes {
		if *p.ResourceType == "publicIPAddresses" {
			resourceType = p
		}
	}

	fmt.Println(resourceType)
	fmt.Println(provider.ResourceTypes)

}

func TestClient3(t *testing.T) {
	client, err := getClient()
	if err != nil {
		fmt.Errorf("%v", err)
	}

	managersClient := client.(*clients.Client).Network.ManagersClient

	parameters := network.Manager{
		Location:          utils.String(location.Normalize("West Europe")),
		ManagerProperties: &network.ManagerProperties{},
	}

	manager, err := managersClient.CreateOrUpdate(context.Background(), parameters, "acctestRG-210407155901671923-henglu", "acctestRG-210407155901671923-henglu")
	if err != nil {
		fmt.Errorf("%v", err)
	}

	fmt.Printf("%v", manager)
}
