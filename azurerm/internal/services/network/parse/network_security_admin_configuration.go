package parse

// NOTE: this file is generated via 'go:generate' - manual changes will be overwritten

import (
	"fmt"
	"strings"

	"github.com/terraform-providers/terraform-provider-azurerm/azurerm/helpers/azure"
)

type NetworkSecurityAdminConfigurationId struct {
	SubscriptionId            string
	ResourceGroup             string
	NetworkManagerName        string
	SecurityConfigurationName string
}

func NewNetworkSecurityAdminConfigurationID(subscriptionId, resourceGroup, networkManagerName, securityConfigurationName string) NetworkSecurityAdminConfigurationId {
	return NetworkSecurityAdminConfigurationId{
		SubscriptionId:            subscriptionId,
		ResourceGroup:             resourceGroup,
		NetworkManagerName:        networkManagerName,
		SecurityConfigurationName: securityConfigurationName,
	}
}

func (id NetworkSecurityAdminConfigurationId) String() string {
	segments := []string{
		fmt.Sprintf("Security Configuration Name %q", id.SecurityConfigurationName),
		fmt.Sprintf("Network Manager Name %q", id.NetworkManagerName),
		fmt.Sprintf("Resource Group %q", id.ResourceGroup),
	}
	segmentsStr := strings.Join(segments, " / ")
	return fmt.Sprintf("%s: (%s)", "Network Security Admin Configuration", segmentsStr)
}

func (id NetworkSecurityAdminConfigurationId) ID() string {
	fmtString := "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/networkManagers/%s/securityConfigurations/%s"
	return fmt.Sprintf(fmtString, id.SubscriptionId, id.ResourceGroup, id.NetworkManagerName, id.SecurityConfigurationName)
}

// NetworkSecurityAdminConfigurationID parses a NetworkSecurityAdminConfiguration ID into an NetworkSecurityAdminConfigurationId struct
func NetworkSecurityAdminConfigurationID(input string) (*NetworkSecurityAdminConfigurationId, error) {
	id, err := azure.ParseAzureResourceID(input)
	if err != nil {
		return nil, err
	}

	resourceId := NetworkSecurityAdminConfigurationId{
		SubscriptionId: id.SubscriptionID,
		ResourceGroup:  id.ResourceGroup,
	}

	if resourceId.SubscriptionId == "" {
		return nil, fmt.Errorf("ID was missing the 'subscriptions' element")
	}

	if resourceId.ResourceGroup == "" {
		return nil, fmt.Errorf("ID was missing the 'resourceGroups' element")
	}

	if resourceId.NetworkManagerName, err = id.PopSegment("networkManagers"); err != nil {
		return nil, err
	}
	if resourceId.SecurityConfigurationName, err = id.PopSegment("securityConfigurations"); err != nil {
		return nil, err
	}

	if err := id.ValidateNoEmptySegments(input); err != nil {
		return nil, err
	}

	return &resourceId, nil
}
