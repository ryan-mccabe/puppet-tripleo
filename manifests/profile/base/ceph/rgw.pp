# Copyright 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::profile::base::ceph::rgw
#
# Ceph RadosGW profile for tripleo
#
# === Parameters
#
# [*keystone_admin_token*]
#   The keystone admin token
#
# [*keystone_url*]
#   The internal or admin url for keystone
#
# [*rgw_key*]
#   The cephx key for the RGW client service
#
# [*step*]
#   (Optional) The current step in deployment. See tripleo-heat-templates
#   for more details.
#   Defaults to hiera('step')
#
class tripleo::profile::base::ceph::rgw (
  $keystone_admin_token,
  $keystone_url,
  $rgw_key,
  $step = hiera('step'),
) {

  include ::tripleo::profile::base::ceph

  if $step >= 3 {
    include ::ceph::profile::rgw
    $rgw_name = hiera('ceph::profile::params::rgw_name', 'radosgw.gateway')
    ceph::key { "client.${rgw_name}":
      secret  => $rgw_key,
      cap_mon => 'allow *',
      cap_osd => 'allow *',
      inject  => true,
    }
  }

  if $step >= 4 {
    ceph::rgw::keystone { $rgw_name:
      rgw_keystone_accepted_roles => ['admin', '_member_', 'Member'],
      use_pki                     => false,
      rgw_keystone_admin_token    => $keystone_admin_token,
      rgw_keystone_url            => $keystone_url,
    }
  }
}
