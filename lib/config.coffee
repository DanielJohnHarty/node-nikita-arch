# Create a user configuration
fs = require 'fs'
prompts = require 'prompts'
path = require 'path'
yaml = require 'js-yaml'

module.exports = ->
  target = path.resolve __dirname, '../conf/user.yaml'
  unless fs.existsSync target
    response = await prompts [
      type: 'text',
      name: 'ssh_ip',
      message: 'SSH target IP',
    ,
      type: 'text',
      name: 'ssh_password',
      message: 'SSH target password',
    ,
      type: 'text',
      name: 'disk_password',
      message: 'Disk encryption password',
    ,
      type: 'text'
      name: 'user_username'
      message: 'Username'
    ,
      type: 'text'
      name: 'user_password'
      message: 'Password'
    ]
    config =
      bootstrap:
        '@nikitajs/core/lib/ssh/open':
          disabled: false
          host: response.ssh_ip
          password: response.ssh_password
          port: 22
        './lib/bootstrap/2.disk':
          lvm:
            passphrase: response.disk_password
        './lib/bootstrap/3.system':
          locales: ['fr_FR.UTF-8', 'en_US.UTF-8']
          timezone: 'Europe/Paris'
          users:
            [response.user_username]:
              password: response.user_password
              sudoer: true
          install_bumblebee: false
      system:
        '@nikitajs/core/lib/ssh/open':
          disabled: false
          host: response.ssh_ip
          username: response.user_username
          password: response.user_password
        './lib/system/2.dev_apps':
          gnome: true
          virtualization: true
          docker: true
          virtualbox: true
          npm_global: true
          atom: true
          nodejs: true
          programming: true
        './lib/system/3.office_apps':
          productivity: true
          font: true
          office: true
    fs.writeFileSync target, yaml.safeDump config