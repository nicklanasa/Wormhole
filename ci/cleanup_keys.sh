#! /usr/bin/env bash

# nuke-certs
#
#
# This script has been reported to help with errors like
#
# this:
# + xcodebuild -exportArchive -exportOptionsPlist /var/folders/rj/8lnf662s3mlgzv5mcq2r2fnc0000gn/T/gym20160216-41694-14bt0ur_config.plist -archivePath '/Users/pe/Library/Developer/Xcode/Archives/2016-02-16/016-02-16 12.09.02.xcarchive' -exportPath /var/folders/rj/8lnf662s3mlgzv5mcq2r2fnc0000gn/T/gym20160216-41694-17mfck9.gym_output
# 2016-02-16 12:10:03.004 xcodebuild[43629:464102] [MT] IDEDistribution: -[IDEDistributionLogging _createLoggingBundleAtPath:]: Created bundle at path '/var/folders/rj/8lnf662s3mlgzv5mcq2r2fnc0000gn/T/016-02-16_12-10-03.003.xcdistributionlogs'.
# 2016-02-16 12:10:03.396 xcodebuild[43629:464102] [MT] IDEDistribution: Step failed: <IDEDistributionSigningAssetsStep: 0x7fbd34d0e550>: Error Domain=IDEDistributionErrorDomain Code=1 "The operation couldn’t be completed. (IDEDistributionErrorDomain error 1.)"
# error: exportArchive: The operation couldn’t be completed. (IDEDistributionErrorDomain error 1.)
# Error Domain=IDEDistributionErrorDomain Code=1 "The operation couldn’t be completed. (IDEDistributionErrorDomain error 1.)"
#
# see https://github.com/fastlane/gym/issues/100
#
# Original credit to @izqui

set -x
set -eou

cd "$TMPDIR"

sudo security delete-certificate -c "Apple Worldwide Developer Relations Certification Authority" /Library/Keychains/System.keychain || true
security delete-certificate -c "Apple Worldwide Developer Relations Certification Authority" /Library/Keychains/login.keychain || true
rm -f "AppleWWDRCA.cer"
curl -O -L http://developer.apple.com/certificationauthority/AppleWWDRCA.cer
security import AppleWWDRCA.cer  -k ~/Library/Keychains/login.keychain -A || true
