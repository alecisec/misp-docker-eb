<?php
$config = array (
  'debug' => 0,
  'MISP' => 
  array (
    'baseurl' => 'misp-dev.infosec.sa.gov.au',
    'footermidleft' => '',
    'footermidright' => '',
    'org' => 'ORGNAME',
    'showorg' => true,
    'threatlevel_in_email_subject' => true,
    'email_subject_TLP_string' => 'TLP Amber',
    'email_subject_tag' => 'tlp',
    'email_subject_include_tag_name' => true,
    'background_jobs' => true,
    'cached_attachments' => true,
    'email' => 'email@address.com',
    'contact' => 'email@address.com',
    'cveurl' => 'http://cve.circl.lu/cve/',
    'disablerestalert' => false,
    'default_event_distribution' => '1',
    'default_attribute_distribution' => 'event',
    'tagging' => true,
    'full_tags_on_event_index' => true,
    'attribute_tagging' => true,
    'full_tags_on_attribute_index' => true,
    'footer_logo' => '',
    'take_ownership_xml_import' => false,
    'unpublishedprivate' => false,
    'disable_emailing' => false,
    'Attributes_Values_Filter_In_Event' => 'id, uuid, value, comment, type, category, Tag.name',
    'uuid' => '5a6567e6-60dc-433e-a97b-0042ac120002',
    'live' => true,
  ),
  'GnuPG' => 
  array (
    'onlyencrypted' => false,
    'email' => '',
    'homedir' => '',
    'password' => '',
    'bodyonlyencrypted' => false,
  ),
  'SMIME' => 
  array (
    'enabled' => false,
    'email' => '',
    'cert_public_sign' => '',
    'key_sign' => '',
    'password' => '',
  ),
  'Proxy' => 
  array (
    'host' => '',
    'port' => '',
    'method' => '',
    'user' => '',
    'password' => '',
  ),
  'SecureAuth' => 
  array (
    'amount' => 5,
    'expire' => 300,
  ),
  'Security' => 
  array (
    'level' => 'medium',
    'salt' => 'MA/o!Vn>ZuaY11W1QLj__k?&*1baJdUs',
    'cipherSeed' => '',
  ),
  'Session.defaults' => 'php',
  'Session.timeout' => 60,
  'Session.autoRegenerate' => true,
  'site_admin_debug' => NULL,
  'Plugin' => NULL,
  'CertAuth' => NULL,
  'ApacheShibbAuth' => NULL,
  'ApacheSecureAuth' => NULL,
);