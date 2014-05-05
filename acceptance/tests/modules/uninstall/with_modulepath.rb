test_name "puppet module uninstall (with modulepath)"

teardown do
  on master, "rm -rf #{master.puppet['confdir']}/modules2"
end

step "Setup"
apply_manifest_on master, <<-PP
file {
  [
    '#{master.puppet['confdir']}/modules2',
    '#{master.puppet['confdir']}/modules2/crakorn',
    '#{master.puppet['confdir']}/modules2/absolute',
  ]: ensure => directory;
  '#{master.puppet['confidr']}/modules2/crakorn/metadata.json':
    content => '{
      "name": "jimmy/crakorn",
      "version": "0.4.0",
      "source": "",
      "author": "jimmy",
      "license": "MIT",
      "dependencies": []
    }';
  '#{master.puppet['confdir']}/modules2/absolute/metadata.json':
    content => '{
      "name": "jimmy/absolute",
      "version": "0.4.0",
      "source": "",
      "author": "jimmy",
      "license": "MIT",
      "dependencies": []
    }';
}
PP

on master, "[ -d #{master.puppet['confdir']}/modules2/crakorn ]"
on master, "[ -d #{master.puppet['confdir']}/modules2/absolute ]"

step "Try to uninstall the module jimmy-crakorn using relative modulepath"
on master, "cd #{master.puppet['confdir']}/modules2 && puppet module uninstall jimmy-crakorn --modulepath=." do
  assert_equal <<-OUTPUT, stdout
\e[mNotice: Preparing to uninstall 'jimmy-crakorn' ...\e[0m
Removed 'jimmy-crakorn' (\e[0;36mv0.4.0\e[0m) from #{master.puppet['confdir']}/modules2
  OUTPUT
end

on master, "[ ! -d #{master.puppet['confdir']}/modules2/crakorn ]"

step "Try to uninstall the module jimmy-absolute using an absolute modulepath"
on master, "cd #{master.puppet['confdir']}/modules2 && puppet module uninstall jimmy-absolute --modulepath=#{master.puppet['confdir']}/modules2" do
  assert_equal <<-OUTPUT, stdout
\e[mNotice: Preparing to uninstall 'jimmy-absolute' ...\e[0m
Removed 'jimmy-absolute' (\e[0;36mv0.4.0\e[0m) from #{master.puppet['confdir']}/modules2
  OUTPUT
end
on master, "[ ! -d #{master.puppet['confdir']}/modules2/absolute ]"
