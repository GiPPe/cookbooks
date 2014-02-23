Data Bags
=========

Data bags are a arbitrary stores of globally available JSON data.  Data Bags
are not directly associated with Node or Role attributes. Data Bags are stored
on the server and indexed for searching. Recipes can load data bags directly,
or search a data bag for specific values similar to attributes in node indexes.

Data Bag Files
--------------

Each Data Bag contains zero or more items uniquely identified by an arbitrary
id. By default ``knife`` will load JSON files from the repository to store them
on the Chef server. However, everything else being Ruby, the ZenOps repository
implements a simple Data Bag DSL on top of Chefs DSL support.

Data Bags are stored in the ``databags`` directory in the Chef repository. Each
Data Bag is represented as a folder containing zero or more Ruby files
representing the Data Bag Items.

Contents of the Data Bag Item can be specified with simple method calls. A
simple Data Bag Item for a user account might look like this::

  name "John Doe"
  email "doe@example.com"
  authorized_keys [
    "ssh-dsa ...",
    "ssh-rsa ..."
  ]

Managing Data Bags
------------------

Data Bags can be managed with one of the provided ``rake`` tasks or the ``knife``
command line client:

**Upload single Data Bag**
  ``rake load:databag[users]``

**Upload all Data Bags**
  ``rake load:databags``

**Listing all data bags**
  ``knife data bag list``

**List items in a Data Bag**
  ``knife data bag list users``

.. note::
   Data Bags should normally not be edited or created with the knife command line client.
   The purpose of the Chef repository is to be the single **authoritative**
   source of information for the infrastructure. Always edit the data bag files and
   upload via ``rake load:databags``.

External Resources
------------------

 * http://wiki.opscode.com/display/chef/Data+Bags
