package backupinstances

import (
	"encoding/json"
	"fmt"
)

type BackupInstance struct {
	CurrentProtectionState    *CurrentProtectionState  `json:"currentProtectionState,omitempty"`
	DataSourceInfo            Datasource               `json:"dataSourceInfo"`
	DataSourceSetInfo         *DatasourceSet           `json:"dataSourceSetInfo,omitempty"`
	DatasourceAuthCredentials AuthCredentials          `json:"datasourceAuthCredentials"`
	FriendlyName              *string                  `json:"friendlyName,omitempty"`
	ObjectType                string                   `json:"objectType"`
	PolicyInfo                PolicyInfo               `json:"policyInfo"`
	ProtectionErrorDetails    *UserFacingError         `json:"protectionErrorDetails,omitempty"`
	ProtectionStatus          *ProtectionStatusDetails `json:"protectionStatus,omitempty"`
	ProvisioningState         *string                  `json:"provisioningState,omitempty"`
}

var _ json.Unmarshaler = &BackupInstance{}

func (s *BackupInstance) UnmarshalJSON(bytes []byte) error {
	type alias BackupInstance
	var decoded alias
	if err := json.Unmarshal(bytes, &decoded); err != nil {
		return fmt.Errorf("unmarshaling into BackupInstance: %+v", err)
	}

	s.CurrentProtectionState = decoded.CurrentProtectionState
	s.DataSourceInfo = decoded.DataSourceInfo
	s.DataSourceSetInfo = decoded.DataSourceSetInfo
	s.FriendlyName = decoded.FriendlyName
	s.ObjectType = decoded.ObjectType
	s.PolicyInfo = decoded.PolicyInfo
	s.ProtectionErrorDetails = decoded.ProtectionErrorDetails
	s.ProtectionStatus = decoded.ProtectionStatus
	s.ProvisioningState = decoded.ProvisioningState

	var temp map[string]json.RawMessage
	if err := json.Unmarshal(bytes, &temp); err != nil {
		return fmt.Errorf("unmarshaling BackupInstance into map[string]json.RawMessage: %+v", err)
	}

	if v, ok := temp["datasourceAuthCredentials"]; ok {
		impl, err := unmarshalAuthCredentialsImplementation(v)
		if err != nil {
			return fmt.Errorf("unmarshaling field 'DatasourceAuthCredentials' for 'BackupInstance': %+v", err)
		}
		s.DatasourceAuthCredentials = impl
	}
	return nil
}
