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

module "gce-lb-http" {
  source      = "GoogleCloudPlatform/lb-http/google"
  version     = "1.0.4"
  name        = "group-http-lb"
  target_tags = ["${module.mig1.target_tags}", "${module.mig2.target_tags}"]
  network     = "${var.gcp_network}"

  backends = {
    "0" = [
      {
        group = "${module.mig1.instance_group}"
      },
      {
        group = "${module.mig2.instance_group}"
      },
    ]
  }

  backend_params = [
    // health check path, port name, port number, timeout seconds.
    "/,http,80,10",
  ]
}
