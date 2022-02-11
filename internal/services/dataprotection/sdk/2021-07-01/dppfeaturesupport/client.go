package dppfeaturesupport

import "github.com/Azure/go-autorest/autorest"

type DppFeatureSupportClient struct {
	Client  autorest.Client
	baseUri string
}

func NewDppFeatureSupportClientWithBaseURI(endpoint string) DppFeatureSupportClient {
	return DppFeatureSupportClient{
		Client:  autorest.NewClientWithUserAgent(userAgent()),
		baseUri: endpoint,
	}
}
