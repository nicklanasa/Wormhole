#!/usr/bin/env ruby

require "pony"

unless ENV["TRAVIS"]
  puts "Must be run from a Travis-CI build. Exiting."
  exit(0)
end

unless ENV["TRAVIS_PULL_REQUEST"] == "false" && ENV["TRAVIS_BRANCH"] == "master"
  puts "Only sending release notification emails for commits against development or master."
  exit(0)
end

repo_name  = `basename \`git rev-parse --show-toplevel\``.strip
version    = `/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" MyReddit/Info.plist`.strip
build      = `git describe --tags`.strip
prev_build = `git describe --abbrev=0 #{build}^`.strip
name       = "#{repo_name} v#{version} (#{build})"
git_log    = `git log #{prev_build}..#{build}`
subject    = "#{name} has been submitted to iTunes Connect"
body       = "#{name} has been submitted to iTunes Connect. Once approved, you should receive an update notification automatically.\n\nThis build includes the following changes:\n\n#{git_log}"

Pony.mail({
  to: "admin@nytekproductions.com",
  via: :smtp,
  via_options: {
    address:              "smtp.gmail.com",
    port:                 587,
    enable_starttls_auto: true,
    user_name:            ENV["RELEASE_EMAIL_ACCOUNT_USERNAME"],
    password:             ENV["RELEASE_EMAIL_ACCOUNT_PASSWORD"],
    authentication:       :plain,
    domain:               "nytekproductions.com"
  },
  subject: subject,
  body: body
})
