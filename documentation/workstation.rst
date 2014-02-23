==================
ZenOps Workstation
==================

Gentoo/Zentoo Linux
===================

TBD

Debian/Ubuntu Linux
===================

TBD

MacOS X
=======

User Account
------------

After booting Mac OS X for the first time a wizard will setup the first user
account. This is the developers' personal account. The credentials should be
obtained from the Welcome Sheet for new employees if applicable.

Admin Account (optional)
------------------------

For recovery and emergency purposes an administrative account may to be
created:

* Open User Management in System Settings
* System Settings -> Users & Groups
* Click on the "+"-button to create a new user with the following data:
* New Account: Administrator
* Full Name: Administrator
* Accountname: administrator
* Password: ask the Head of Security
* Password Hint: leave empty

Activate FileVault Disk Encryption
----------------------------------

The filesystem should be encrypted and you should activate decryption for
the Administrator account:

* Open security settings
* System Settings -> Security & Privacy -> FileVault
* Turn On FileVault
* Enable User ...
* Enter the Administrator Password
* Continue and do not store the Recovery Key with Apple
* Reboot in order to start the encryption process

The encryption process will take about one hour but bootstrapping can be done
simultaneously.

Install Xcode & Command Line Tools
----------------------------------

You need to install Xcode from the App Store:

* Start App Store
* Install Xcode

As soon as Xcode has been installed you need to install the Command Line Tools from within XCode:

* Start Xcode
* Install the necessary Frameworks if you are prompted to do so
* Go to Preferences -> Downloads
* Install Command Line Tools
* Wait for the installation to finish
* Quit Xcode

.. todo::

   Xcode changes in MacOS X 10.9 have not yet been fully tested.

Chef Bootstrap
--------------

Everything else will be installed and configured with chef.

* Open Terminal.app
* ``git clone https://github.com/zenops/cookbooks ~/chef && cd ~/chef``
* ``./bin/chef``
* During the installation you will be presented with various dialogues since
  not every aspect of a MacOS setup can be done from the command line:

  * You will be prompted to install Java.
  * iTerm will open and tell you that the Solarized Dark color scheme has been
    imported. You need to select it manually though.

    * Go to Preferences -> Profiles
    * Click on Load Presets and select Solarized Dark

* On the first run Chef will take a long time to download and compile all aplications
* Subsequent runs will be fast since Chef automatically skips already configured applications.


Push your changes
=================

If you want to use the same configuration on multiple machines you should
create a fork of this repository and push your changes.
