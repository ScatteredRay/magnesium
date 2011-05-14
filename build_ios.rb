require 'rubygems'
require 'mustache'
require 'plist'
require 'cache'

module Build_iOS extend self

  def unexpected_error(error_message)
  end

  def gen_build_path(user_id, project_id, build_slot)
    return File.expand_path("~/user_builds/#{user_id}/#{project_id}_#{build_slot}")
  end

  def gen_temp_ipa_path(user_id, project_id, build_slot)
    return File.expand_path("~/user_builds/ipas/#{user_id}_#{project_id}_#{build_slot}.ipa")
    end

  def copy_ipa(ipa, user_id, project_id, build_slot)
    # This probally should happen on install, and not on every build.
    FileUtils.mkpath(File.expand_path("~/user_builds/ipas"))

    ipa_path = gen_temp_ipa_path(user_id, project_id, build_slot)

    FileUtils.cp(ipa, ipa_path)

    return ipa_path
  end

  def clean_build(build_directory)
    # Just going to kill the whole directory.
    # Keeping it around may make sense to speed up
    # builds later on if we can figure out how to
    # clean it and patch it properlly.

    FileUtils.remove_dir(build_directory)
  end

  def init_build_directory(build_directory, repo)
    if(File.exists?(build_directory))
      # Error if we aren't expecting this!
      # unexpected_error("Build directory #{build_directory} already exists.")
      return
    end

    FileUtils.mkpath(build_directory);

    Cache.cache_get(repo, build_directory);
  end

  def install_certificate(dev_cert)
    # Take care of certs and provisioning profiles.
    cert_pass = "1233456789" # Perhaps we should generate this randomlly?
    #system("security import #{dev_cert} -k ~/Library/Keychains/login.keychain -P #{cert_pass} -T /usr/bin/codesign")
    # *.xcodeproj/project.pbxproj has CODE_SIGN_IDENTITY make sure those match the cert. just installed.
  end

  def run_xcode_build(build_directory, proj_name, target, config_name, sdk_name, ret_str)
    # Do the build.
    source_dir = Dir.pwd
    Dir.chdir(build_directory);

    ret = `xcodebuild -project #{proj_name} -target #{target} -configuration #{config_name} -sdk #{sdk_name}`

    ret_str.replace(ret)
    Dir.chdir(source_dir);

    if($?.exitstatus == 0)
      return true;
    else
      return false;
    end
  end

  def parse_project(build_directory, proj_name)
    # convert to xml
    projfile = "#{build_directory}/#{proj_name}/project.pbxproj"
    xmlproj = "#{build_directory}/project.xmlproj"
    err = `plutil -convert xml1 -o #{xmlproj} #{projfile}`

    if($?.exitstatus != 0)
      unexpected_error(err)
    end

    proj = Plist::parse_xml(xmlproj)

    oroot = proj["rootObject"]
    objects = proj["objects"]

    rproject = Hash.new

    objects[oroot]["targets"].each do |otarget|
      rtarget = Hash.new
      rproject[objects[otarget]["name"]] = rtarget

      obuildconfs = objects[otarget]["buildConfigurationList"]

      objects[obuildconfs]["buildConfigurations"].each do |obuildconf|
        settings = objects[obuildconf]["buildSettings"]
	
	rsettings = Hash.new
	rtarget[objects[obuildconf]["name"]] = rsettings

	# Check that it is a string or $(TARGET_NAME)
	rsettings["product_name"] = settings["PRODUCT_NAME"].gsub("$(TARGET_NAME)", objects[otarget]["name"])
	rsettings["plist_file"] = settings['INFOPLIST_FILE']
      end
    end

    return rproject
  end

  def parse_info_plist(build_directory, project, target, conf, bundle_id, version)
     plistfile = "#{build_directory}/#{project[target][conf]['plist_file']}"
     plist = Plist::parse_xml(plistfile)

     product_name = project[target][conf]["product_name"]
     bundle_id.replace(plist['CFBundleIdentifier'].gsub("${PRODUCT_NAME:rfc1034identifier}", product_name.downcase))
     version.replace(plist['CFBundleVersion'])
  end

  def build_ipa(build_directory, config_name, target)
    source_dir = Dir.pwd
    build_path = build_directory + "/build/#{config_name}-iphoneos"
    app_path = build_path + "/#{target}.app"
    ipa_path = build_path + "/#{target}.ipa"
    payload = build_path + "/payload/"

    # Fail on error here.
    Dir.mkdir(payload)
    FileUtils.cp_r(app_path, payload)

    Dir.chdir(build_path)
    ret = `zip -r #{target}.ipa payload`
    Dir.chdir(source_dir);

    if($?.exitstatus != 0)
      # This shouldn't fail, figure out when it does and how to fix it.
      unexpected_error(ret)
    end

    return ipa_path;
  end

  def render_manifest(build_directory, dest_url, target, config, project)
    Mustache.template_file = "manifest.plist"
    view = Mustache.new
    view[:PackageUrl] = dest_url + "#{target}.ipa"
    view[:DisplayImageUrl] = dest_url + "Icon.png"
    view[:FullImageUrl] = dest_url + "Icon.png"

    bundle_id = ''
    version = ''
    parse_info_plist(build_directory, project, target, config, bundle_id, version)

    view[:BundleId] = bundle_id # This comes from .mobileprovision
    view[:Version] = version # Where does this come from?
    view[:Title] = target # Does this seem resonable
    return view.render()
  end
end
