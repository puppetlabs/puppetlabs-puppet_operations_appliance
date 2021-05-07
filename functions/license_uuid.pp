# @return [String]  the uuid from a Puppet license file supplied in $content
# If no $content parameter specified, tries to read the license file
# from /etc/puppetlabs/license.key
# @param [Optional[String]] content
#   An array of rsan ip addresses
#   Defaults to the output of a PuppetDB query
function rsan::license_uuid(Optional[String] $content) >> String {
  $license_file_path = '/etc/puppetlabs/license.key'
  if $content {
    $_content = parseyaml($content)
  } else {
    $_content = load_yaml($license_file_path)
  }
  return $_content['uuid']
}
