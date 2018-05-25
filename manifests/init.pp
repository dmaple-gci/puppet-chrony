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
  String  $config             = '/etc/chrony.conf',
  String  $config_template    = 'chrony.conf.erb',
  String  $driftfile          = '/var/lib/chrony/drift',
  String  $logdir             = '/var/log/chrony',
  Boolean $iburst_enable      = true,
  Boolean $keys_enable        = false,
  String  $keys_file          = '/etc/chrony.keys',
  Numeric $makestep_threshold = 1.0,
  Integer $makestep_limit     = 3,
  String  $package_ensure     = 'present',
  Array   $package_name       = ['chrony'],
  Array   $preferred_servers  = [],
  Boolean $rtcsync            = true,
  Array   $servers            = ['0.centos.pool.ntp.org','1.centos.pool.ntp.org','2.centos.pool.ntp.org'],
  Boolean $service_enable     = true,
  String  $service_ensure     = 'running',
  Boolean $service_manage     = true,
  String  $service_name       = 'chronyd',
) {


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

