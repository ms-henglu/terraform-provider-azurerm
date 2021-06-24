package resource

import (
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"os"
	"strconv"
)

func isSdkDiffCheckEnabled() bool {
	if enabled, err := strconv.ParseBool(os.Getenv("TF_ACC_SDK_DIFF_CHECK")); err == nil {
		return enabled
	}
	return true
}

func getSdkDiffCheckProvider() string {
	if provider := os.Getenv("TF_ACC_PROVIDER"); provider != "" {
		return provider
	}
	return "azurerm"
}

func getSdkDiffCheckProviderVersion() string {
	if provider := os.Getenv("TF_ACC_PROVIDER_VERSION"); provider != "" {
		return provider
	}
	return "2.62.1"
}

func useExternalProvider(c TestCase) func() (*schema.Provider, error) {
	if isSdkDiffCheckEnabled() {
		provider := getSdkDiffCheckProvider()
		c.ExternalProviders[provider] = ExternalProvider{
			VersionConstraint: "=" + getSdkDiffCheckProviderVersion(),
			Source:            "registry.terraform.io/hashicorp/" + provider ,
		}
		backupProviderFactory := c.ProviderFactories[provider]
		delete(c.ProviderFactories, provider)
		return  backupProviderFactory
	}
	return nil
}

func useDevelopProvider(c TestCase, backupProviderFactory func() (*schema.Provider, error)) {
	if isSdkDiffCheckEnabled() {
		provider := getSdkDiffCheckProvider()
		c.ProviderFactories[provider] = backupProviderFactory
		delete(c.ExternalProviders, provider)
	}
}