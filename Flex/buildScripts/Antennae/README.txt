################################################################
# Copyright (c) 2007-2008 Allurent, Inc.
# http://code.google.com/p/antennae/
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
################################################################

* INTRODUCTION

This is a set of self-guiding progressive samples developed to
illustrate the use of Ant with Flex, based on some simple "toy"
projects.  It does not assume any existing knowledge of Ant, but does
assume the user has access to Ant reference materials.

Tools are provided to automate the running of FlexUnit tests.

Additionally a set of quick start templates is provided to make it
easy to get new projects up and running quickly.

For the latest information, bug reporting, and enhancement requests,
please see:

http://code.google.com/p/antennae/

* REQUIREMENTS

Ant 1.6.5 or newer is required (along with an Ant compatible JDK):
http://ant.apache.org/

Flex SDK (or Flex Builder):
http://www.flex.org/

* INSTALLATION

Unpack the Antennae.zip directory into a location of your choice.

Create a custom build-user.properties (see below in the CONTENTS
section).

* CONTENTS

build.xml
    Top level build file that can be used to execute the standard
    targets on all sample projects in Antennae.
    
build-imports.xml
    Top level import file that specifies where the common Ant
    files are located and pulls in all of the build-asset.xml
    files.
    
build-assets.xml
    Top level build asset file that specifies the location of all
    other build-assets.xml files that should be referenced by Ant.

build-user.properties.*
    Sample build-user.properties files. Based on your system
    configuration you might want to copy one of these files to
    build-user.properties and customize it to your system.

LICENSE.txt
    Information on the license that this project is released
    under.
    
NOTICE.txt
    Notice about other software that this project uses.

lib/
    External tools needed to compile and run FlexUnit tests from
    the command line.

tools/
    Common Ant targets and tasks that are shared across all
    projects.
    
templates/
    Directory structure and build files that can be easily copied
    and used to jump start development. See the README.txt in this
    directory for additional information.

tutorial/
    Example projects that use Ant to perform various project
    compilation and testing scenarios. See the README.txt in this
    directory for additional information. These are designed to
    help introduce Ant.

* BUILD PHILOSOPHY

Ant is a build tool. It is designed to automate the process of
building software.  Building complex software often involves multiple
assets and intermediate steps that can get hairy to keep track of. Ant
helps capture the interdependencies to make sure that a reliable and
repeatable build process is created. This section is designed to
introduce how Antennae structures its build process.

properties
    The most important thing to remember about properties with Ant
    is that whoever sets a property first, wins. This means that
    overrides of default properties need to happen before the
    default property settings are imported.
    
targets
    If a target in the main file is also present in at least one
    of the imported files, the one from the main file takes
    precedence.

build.xml
    Each project that requires or aggregates build information
    specifies a build.xml file. Each build.xml file in Antennae
    follows the same basic structure: project properties, imports,
    target overrides, custom targets.  It will probably be helpful
    to have both tutorial/build*.xml and tutorial/app2/build*.xml
    as references when reading the rest of this section.

    Each build.xml file has a name attribute defined at the top in
    the project element that needs to be unique. This allows
    referring to targets defined in other files.
    
project properties
    The shared build logic relies on an individual project to
    define pieces that are unique to it. Antennae defines
    reasonable defaults, but if a particular project uses a
    different structure, such as placing the source code in a
    different folder, the project specific properties will take
    precedence over any imported default. It is important that
    these project specific properties appear before any import
    statements.
    
    For certain targets, Antennae requires that a path be set and
    does not provide a default. This is done to avoid warning
    messages from Ant and in most cases the path would needs to be
    overridden anyway. Examples of this behavior are:

    <path id="flex.lib.path" />
          Must be defined for any flex related target
    <path id="javac.lib.path" />
          Must be defined for any java related target

    If such a path hasn't been defined a build failure such as
    this will occur:

    Reference flex.lib.path not found.
    
    It is okay to define an empty path like the two shown above.
    
imports
    The import mechanism used by Antennae helps share code,
    centralize configuration, and make it easy to change how the
    build works. To accomplish this Antennae uses two types of
    imports: build-imports.xml which walk up the directory
    hierarchy and build-assets.xml that walk down the directory
    hierarchy.
    
    The build-imports.xml are designed to pull in shared code and
    centralized configuration into individual projects. In most
    cases a build-imports.xml file will just reference its parent
    and not do anything itself. Most of the sample
    build-imports.xml files included in Antennae follow this
    pattern.
    
    The primary exception is the build-imports.xml defined at the
    top location.  This build-imports.xml is responsible for
    loading the centralized configuration, pulling in all the
    shared building code, and kicking off walking down the
    directory hierarchy through the use of build-assets.xml.
    
    The build-assets.xml are designed to specify the output of
    building different pieces of software that can be used by
    other pieces of the system. For example you might have a .swc
    that is used by two other projects. The location of that .swc
    would be captured in a build-assets.xml file that when pulled
    in would allow other projects to reference the exported
    property.
    
    Each build-imports.xml and build-assets.xml file has a name
    attribute defined at the top in the project element that needs
    to be unique. This allows referring to targets defined in
    other files.
    
target overrides
    Antennae defines a set of top level build targets that
    represent the standard steps of building software. These are:
    init, build, test, stage, dist, deploy, clean, and
    undeploy. They are described below:

    init: Used to setup the directories needed for all the other
    targets

    build: Used to build the software, this mostly consists of
    just compiling information

    test: Used to run automated tests to verify that what was
    built is working correctly

    stage: Used to copy files and create a directory structure
    that mirrors the distribution

    dist: Used to create the distribution that will be given to
    others

    deploy: Used to deploy the distribution to a location

    clean: Used to remove everything that all of the other targets
    created, expect deploy

    undeploy: Used to undeploy the distribution

    The default implementation of these targets, excluding init
    and clean, do nothing.  The reason that they exist is to make
    it easy to define only the targets that are special for a
    project while still being able to call other targets without
    risking an error from Ant. These targets can also be used by
    other shared targets to make sure that dependencies are
    satisfied, such as making sure the init target has been called
    before compiling classes.
    
custom targets
    Often there is enough logic in an Ant target that it should be
    broken out into its own target. Custom targets are the last
    piece Antennae defines in a build.xml file. If the same target
    starts to appear in more than one build file that is usually
    an indication that it should be added to the common build
    files.


