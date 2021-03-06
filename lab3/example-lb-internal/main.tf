/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider google {
  version = "~> 1.16.0"

  credentials = "${file("${var.gcp_credentials_file_path}")}"

  # Should be able to parse project from credentials file but cannot.
  # Cannot convert string to map and cannot interpolate within variables.
  project = "${var.gcp_project_id}"

  region = "${var.gcp_region}"
}

module "gce-lb-fr" {
  source       = "GoogleCloudPlatform/lb/google"
  version      = "1.0.2"
  region       = "${var.gcp_region}"
  network      = "${var.gcp_network}"
  name         = "group1-lb"
  service_port = "${module.mig1.service_port}"
  target_tags  = ["${module.mig1.target_tags}"]
}

module "gce-ilb" {
  source       = "GoogleCloudPlatform/lb-internal/google"
  version      = "1.0.4"
  region      = "${var.gcp_region}"
  name        = "group-ilb"
  ports       = ["${module.mig2.service_port}"]
  health_port = "${module.mig2.service_port}"
  source_tags = ["${module.mig1.target_tags}"]
  target_tags = ["${module.mig2.target_tags}", "${module.mig3.target_tags}"]

  backends = [
    {
      group = "${module.mig2.instance_group}"
    },
    {
      group = "${module.mig3.instance_group}"
    },
  ]
}
