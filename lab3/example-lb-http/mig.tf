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

variable group1_size {
  default = "2"
}

variable group2_size {
  default = "2"
}

data "template_file" "group-startup-script" {
  template = "${file("${format("%s/gceme.sh.tpl", path.module)}")}"

  vars {
    PROXY_PATH = ""
  }
}

module "mig1" {
  source            = "GoogleCloudPlatform/managed-instance-group/google"
  version           = "1.1.0"
  region            = "${var.gcp_region}"
  zone              = "${var.gcp_zone}"
  network           = "${var.gcp_network}"
  name              = "group1"
  size              = "${var.group1_size}"
  target_tags       = ["allow-group1"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group-startup-script.rendered}"
}

module "mig2" {
  source            = "GoogleCloudPlatform/managed-instance-group/google"
  version           = "1.1.0"
  region            = "${var.gcp_region2}"
  zone              = "${var.gcp_zone2}"
  network           = "${var.gcp_network}"
  name              = "group2"
  size              = "${var.group2_size}"
  target_tags       = ["allow-group2"]
  service_port      = 80
  service_port_name = "http"
  startup_script    = "${data.template_file.group-startup-script.rendered}"
}
