test_name "puppet module list (with modulepath)"

step "Setup"
apply_manifest_on master, <<-PP
file {
  [
    '#{master.puppet['confdir']}/modules2',
    '#{master.puppet['confdir']}/modules2/crakorn',
    '#{master.puppet['confdir']}/modules2/appleseed',
    '#{master.puppet['confdir']}/modules2/thelock',
  ]: ensure => directory,
     recurse => true,
     purge => true,
     force => true;
  '#{master.puppet['confdir']}/modules2/crakorn/metadata.json':
    content => '{
      "name": "jimmy/crakorn",
      "version": "0.4.0",
      "source": "",
      "author": "jimmy",
      "license": "MIT",
      "dependencies": []
    }';
  '#{master.puppet['confdir']}/modules2/appleseed/metadata.json':
    content => '{
      "name": "jimmy/appleseed",
      "version": "1.1.0",
      "source": "",
      "author": "jimmy",
      "license": "MIT",
      "dependencies": [
        { "name": "jimmy/crakorn", "version_requirement": "0.4.0" }
      ]
    }';
  '#{master.puppet['confdir']}/modules2/thelock/metadata.json':
    content => '{
      "name": "jimmy/thelock",
      "version": "1.0.0",
      "source": "",
      "author": "jimmy",
      "license": "MIT",
      "dependencies": [
        { "name": "jimmy/appleseed", "version_requirement": "1.x" }
      ]
    }';
}
PP

teardown do
  on master, "rm -rf #{master.puppet['confdir']}/modules2"
end

on master, "[ -d #{master.puppet['confdir']}/modules2/crakorn ]"
on master, "[ -d #{master.puppet['confdir']}/modules2/appleseed ]"
on master, "[ -d #{master.puppet['confdir']}/modules2/thelock ]"

step "List the installed modules with relative modulepath"
on master, "cd #{master.puppet['confdir']}/modules2 && puppet module list --modulepath=." do
  assert_equal <<-STDOUT, stdout
#{master.puppet['confdir']}/modules2
├── jimmy-appleseed (\e[0;36mv1.1.0\e[0m)
├── jimmy-crakorn (\e[0;36mv0.4.0\e[0m)
└── jimmy-thelock (\e[0;36mv1.0.0\e[0m)
STDOUT
end

step "List the installed modules with absolute modulepath"
on master, puppet("module list --modulepath=#{master.puppet['confdir']}/modules2") do
  assert_equal <<-STDOUT, stdout
#{master.puppet['confdir']}/modules2
├── jimmy-appleseed (\e[0;36mv1.1.0\e[0m)
├── jimmy-crakorn (\e[0;36mv0.4.0\e[0m)
└── jimmy-thelock (\e[0;36mv1.0.0\e[0m)
STDOUT
end
