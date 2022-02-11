package backuppolicies

import (
	"encoding/json"
	"fmt"
)

type TargetCopySetting struct {
	CopyAfter CopyOption        `json:"copyAfter"`
	DataStore DataStoreInfoBase `json:"dataStore"`
}

var _ json.Unmarshaler = &TargetCopySetting{}

func (s *TargetCopySetting) UnmarshalJSON(bytes []byte) error {
	type alias TargetCopySetting
	var decoded alias
	if err := json.Unmarshal(bytes, &decoded); err != nil {
		return fmt.Errorf("unmarshaling into TargetCopySetting: %+v", err)
	}

	s.DataStore = decoded.DataStore

	var temp map[string]json.RawMessage
	if err := json.Unmarshal(bytes, &temp); err != nil {
		return fmt.Errorf("unmarshaling TargetCopySetting into map[string]json.RawMessage: %+v", err)
	}

	if v, ok := temp["copyAfter"]; ok {
		impl, err := unmarshalCopyOptionImplementation(v)
		if err != nil {
			return fmt.Errorf("unmarshaling field 'CopyAfter' for 'TargetCopySetting': %+v", err)
		}
		s.CopyAfter = impl
	}
	return nil
}
