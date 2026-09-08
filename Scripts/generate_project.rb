#!/usr/bin/env ruby
require 'xcodeproj'
root = File.expand_path('..', __dir__)
project = Xcodeproj::Project.new(File.join(root, 'DevDay2026.xcodeproj'))
shared = Dir[File.join(root, 'Shared/*.swift')] + [File.join(root, 'Shared/Assets.xcassets')]
refs = {}
(shared + Dir[File.join(root, '{App,Widget}/*.swift')]).each { |p| refs[p] = project.main_group.new_file(p.delete_prefix(root + '/')) }
[['iOS', :ios, '17.0'], ['Mac', :osx, '14.0']].each do |label, platform, version|
  app = project.new_target(:application, "DevDay#{label}", platform, version)
  widget = project.new_target(:app_extension, "DevDay#{label}Widget", platform, version)
  [[app, 'App'], [widget, 'Widget']].each do |target, folder|
    target.add_file_references((shared + Dir[File.join(root, "#{folder}/*.swift")]).map { |p| refs[p] })
    target.build_configurations.each do |config|
      s = config.build_settings
      s['SWIFT_VERSION'] = '5.0'
      s['PRODUCT_BUNDLE_IDENTIFIER'] = "community.devday.countdown.#{label.downcase}" + (folder == 'Widget' ? '.widget' : '')
      s['GENERATE_INFOPLIST_FILE'] = 'YES'
      s['INFOPLIST_KEY_CFBundleDisplayName'] = 'DevDay 2026'
      s['MARKETING_VERSION'] = '1.0.0'
      s['CURRENT_PROJECT_VERSION'] = '1'
      s['CODE_SIGN_STYLE'] = 'Automatic'
      s['DEVELOPMENT_TEAM'] = ''
      s['INFOPLIST_FILE'] = "#{folder}/Info.plist"
      s['ENABLE_APP_SANDBOX'] = 'YES' if platform == :osx
      s['CODE_SIGN_ENTITLEMENTS'] = 'App/Mac.entitlements' if platform == :osx
      if platform == :ios
        s['TARGETED_DEVICE_FAMILY'] = '1,2'
        s['INFOPLIST_KEY_UILaunchScreen_Generation'] = 'YES'
        s['INFOPLIST_KEY_UIApplicationSceneManifest_Generation'] = 'YES'
        s['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone'] = 'UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
        s['INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad'] = 'UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight'
      end
      s['APPLICATION_EXTENSION_API_ONLY'] = 'YES' if folder == 'Widget'
      s['SKIP_INSTALL'] = 'YES' if folder == 'Widget'
    end
  end
  app.add_dependency(widget)
  embed = app.new_copy_files_build_phase('Embed Widget Extension')
  embed.dst_subfolder_spec = '13'
  embed.add_file_reference(widget.product_reference).settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }
  scheme = Xcodeproj::XCScheme.new
  scheme.add_build_target(app)
  scheme.set_launch_target(app)
  scheme.save_as(project.path, app.name, true)
end
project.save
