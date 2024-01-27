// Copyright 2024 Michael Vittrup Larsen
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"fmt"
	"os"

	gatortest "github.com/open-policy-agent/gatekeeper/v3/pkg/gator/test"
	gatekeeperutil "github.com/open-policy-agent/gatekeeper/v3/pkg/util"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"sigs.k8s.io/kustomize/kyaml/fn/framework"
	"sigs.k8s.io/kustomize/kyaml/fn/framework/command"
	"sigs.k8s.io/kustomize/kyaml/yaml"
	k8syaml "sigs.k8s.io/yaml"
)

type GatorTest struct{}

func (gator *GatorTest) Process(resourceList *framework.ResourceList) error {
	var results framework.Results
	results = append(results, &framework.Result{
		Message: "gatekeeper",
	})
	var objects []*unstructured.Unstructured
	for _, item := range resourceList.Items {
		s, err := item.String()
		if err != nil {
			return err
		}

		un := &unstructured.Unstructured{}
		err = k8syaml.Unmarshal([]byte(s), un)
		if err != nil {
			return err
		}

		objects = append(objects, un)
	}

	responses, err := gatortest.Test(objects, gatortest.Opts{IncludeTrace: false, GatherStats: false, UseK8sCEL: false})
	if err != nil {
		return err
	}

	for _, result := range responses.Results() {
		res := framework.Result{
			Message: fmt.Sprintf("%s violatedConstraint: %s", result.Msg, result.Constraint.GetName()),
			ResourceRef: &yaml.ResourceIdentifier{
				TypeMeta: yaml.TypeMeta{
					APIVersion: result.ViolatingObject.GetAPIVersion(),
					Kind:       result.ViolatingObject.GetKind(),
				},
				NameMeta: yaml.NameMeta{
					Name:      result.ViolatingObject.GetName(),
					Namespace: result.ViolatingObject.GetNamespace(),
				},
			},
		}
		switch result.EnforcementAction {
		case string(gatekeeperutil.Dryrun):
			res.Severity = framework.Info
		case string(gatekeeperutil.Warn):
			res.Severity = framework.Warning
		default:
			res.Severity = framework.Error
		}
		results = append(results, &res)
	}

	resourceList.Results = results
	return nil
}

func main() {
	gator := GatorTest{}
	cmd := command.Build(&gator, command.StandaloneEnabled, false)

	if err := cmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
