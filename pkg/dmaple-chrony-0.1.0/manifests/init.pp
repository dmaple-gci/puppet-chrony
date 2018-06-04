# == Class: chrony
#
# Full description of class chrony here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'chrony':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2018 Your name here, unless otherwise noted.
#
class chrony (
  $config             = '/etc/chrony.conf',
  $config_template    = 'chrony.conf.erb',
  $driftfile          = '/var/lib/chrony/drift',
  $logdir             = '/var/log/chrony',
  $iburst_enable      = true,
  $keys_enable        = false,
  $keys_file          = '/etc/chrony.keys',
  $makestep_threshold = 1.0,
  $makestep_limit     = 3,
  $package_ensure     = 'present',
  $package_name       = ['chrony'],
  $preferred_servers  = [],
  $rtcsync            = true,
  $servers            = ['0.centos.pool.ntp.org','1.centos.pool.ntp.org','2.centos.pool.ntp.org'],
  $service_enable     = true,
  $service_ensure     = 'running',
  $service_manage     = true,
  $service_name       = 'chronyd',
) {

  # Validate parameters
  #
  validate_absolute_path($config)
  validate_string($config_template)
  validate_absolute_path($driftfile)
  if $logdir { validate_absolute_path($logdir) }
  validate_bool($iburst_enable)
  validate_bool($keys_enable)
  validate_absolute_path($keys_file)
  validate_numeric($makestep_threshold)
  validate_integer($makestep_limit)
  validate_string($package_ensure)
  validate_array($package_name)
  validate_array($preferred_servers)
  validate_bool($rtcsync)
  validate_array($servers)
  validate_bool($service_enable)
  validate_string($service_ensure)
  validate_bool($service_manage)
  validate_string($service_name)

  # On virtual machines allow large clock skews.
  $panic = str2bool($::is_virtual) ? {
    true    => false,
    default =>  true,
  }
  
  # Install package
  #
  package { $package_name:
    ensure =>  $package_ensure,
  }

  # Configuration
  #
  if $keys_enable {
    $directory = ntp_dirname($keys_file)
    file { $directory:
      ensure =>  directory,
      owner  =>  0,
      group  =>  0,
      mode   =>  '0755',
    }
  }
  
  file { $config:
    ensure  =>  file,
    owner   =>  0,
    group   =>  0,
    mode    =>  '0644',
    content =>  template("${module_name}/$config_template"),
  }

  # Setup the service
  #
  if ! ($service_ensure in [ 'running', 'stopped' ]) {
    fail('service_ensure parameter must be running or stopped')
  }
  
  if $service_manage == true {
    service { 'ntp':
      ensure     =>  $service_ensure,
      enable     =>  $service_enable,
      name       =>  $service_name,
      hasstatus  =>  true,
      hasrestart =>  true,
    }
  }
}

