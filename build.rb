require 'build_ios'

# On single machine build systems we want the build process to spawn these,
# however on single purpose build machines, this will be the prefered method.
# Then just combined with some sort of general daemon interface.
Build = Build_iOS
