Getting Started
===============

Chef
----

Chef is a systems and infrastructure automation framework that makes it
easy to deploy servers and applications to any physical, virtual, or cloud
location, no matter the size of the infrastructure.

Chef is based on a key insight: You can model your evolving IT infrastructure
and applications as code. Chef makes no assumptions about your environment and
the approach you use to configure and manage it. Instead, Chef gives you a way
to describe and automate your infrastructure and processes. Your infrastructure
becomes testable, versioned and repeatable. It becomes part of your Agile
process.

Chef relies on reusable definitions known as cookbooks and recipes that are
written using the the Ruby programming language. Cookbooks and recipes automate
common infrastructure tasks. Their definitions describe what your
infrastructure consists of and how each part of your infrastructure should be
deployed, configured and managed. Chef applies those definitions to
workstations and servers to produce an automated infrastructure.

Repository
----------

The ZenOps Chef repository uses `RVM <http://rvm.io>`_ and `Bundler
<http://bundler.io>`_ to manage ruby and dependencies required by Chef.

To start your own copy of this repository `fork the repository
<https://github.com/zenops/cookbooks/fork>`_ and bootstrap
your local environment::

  git clone https://github.com/zenops/cookbooks chef && cd chef
  ./scripts/bootstrap

We suggest to :doc:`setup your workstation </workstation>` with Chef too!
