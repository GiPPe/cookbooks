#!/usr/bin/python -tt
"""
Libusers - a script that finds users of libs that have been deleted/replaced
"""

# Copyright 2010 Tobias Klausmann
# Released under the GPL-2

import sys
import glob
import fnmatch, re
import subprocess

from os.path import normpath
from collections import defaultdict

PROCFSPAT = "/proc/*/maps"
PROCFSBASE = "/proc/"
PERMWARNING = """\
Warning: Some files could not be read. Note that lib_users has to be run as
root to get a full list of deleted in-use libraries.\n"""
__version__ = "0.5"

# These are no true libs so don't make our process a deleted libs user
NOLIBS = [
    "/SYSV*",
    "/[aio]",
    "/dev/zero",
    "/dev/shm/*",
    "*/var/nagios/spool/checkresults/neb*",
    "/tmp/hsperfdata*",
    "/tmp/jna/*",
    "/tmp/winstone*",
    "/usr/lib/lxc/rootfs/*",
    "/usr/lib64/lxc/rootfs/*",
    "/var/app/druid/*",
    "/var/app/kafka/storage/*",
    "/var/tmp/hadoop/*",
    "/var/app/hadoop2/*",
]

FP_EXCLUDES = [
    "/lib/udev/udevd",
]

def get_deleted_libs(map_file):
    """
    Get all deleted libs from a given map file and return them as a set
    """
    deletedlibs = set()

    for line in map_file:
        line = line.strip()
        if line.endswith("(deleted)"):
            lib = line.split()[-2]
            is_lib = all(lib != pattern and not fnmatch.fnmatch(lib, pattern)
                         for pattern in NOLIBS)
            if is_lib:
                deletedlibs.add(lib)

    return deletedlibs

def get_progargs(pid):
    """
    Get argv for a given PID and return it as a list
    """
    try:
        argv = open("%s/%s/cmdline" % (PROCFSBASE, pid)).read()
    except IOError:
        return None
    argv = argv.split('\x00')
    argv = [ e.strip() for e in argv ]
    argv = " ".join(argv)
    return argv

def fmt_machine(lib_users):
    """
    Format a list of library users into a machine-readable table

    Args:
     lib_users: Dict of library users, keys are argvs (as string), values are
     tuples of two sets, first listing the libraries used, second listing the
     PIDs: { argv: ({lib, lib, ...}, {pid, pid, ...}), argv: ... }
    Returns:
     A multiline string for machine consumption
    """
    # Usually, users don't care about what libs exactly are used
    res = []
    for argv, pidslibs in lib_users.iteritems():
        pidlist = ",".join(sorted(pidslibs[0]))
        libslist = ",".join(sorted(pidslibs[1]))
        res.append("%s;%s;%s" % (pidlist, libslist, argv.strip()))
    return "\n".join(res)

def restart_services(lib_users):
    services = {}
    for argv, pidslibs in lib_users.iteritems():
        for pid in pidslibs[0]:
            try:
                with open('/proc/{0}/cgroup'.format(pid), 'r') as cgroups:
                    for cgroup in cgroups.readlines():
                        if 'systemd' in cgroup:
                            service = cgroup.strip().split('/')[-1]
                            if service != '':
                                services[service] = pidslibs[1]
            except IOError as e:
                print('PID {0} went away (or permission denied): {1}'.format(pid, e))

    for service in fnmatch.filter(set(services), '*.service'):
        print 'Restarting {0} ...'.format(service),
        sys.stdout.flush()
        subprocess.check_output(['/usr/bin/systemctl', 'restart', service], stderr=subprocess.STDOUT)
        print('done')

def main(restart=False):
    """Main program"""
    all_map_files = glob.glob(PROCFSPAT)
    users = {}
    users = defaultdict(lambda: (set(), set()))
    read_failure = False
    for map_filename in all_map_files:
        try:
            pid = normpath(map_filename).split("/")[2]
        except IndexError:
            # This happens if the filenames look different
            # than we expect (e.g. the user changed PROCFSPAT)
            pid = "unknown"

        try:
            mapsfile = open(map_filename)
        except IOError:
            # The file is unreadable for us, so skip it silently
            continue

        try:
            deletedlibs = get_deleted_libs(mapsfile)
        except IOError:
            read_failure = True
            continue

        if len(deletedlibs) > 0:
            argv = get_progargs(pid)
            is_fp = any(re.match(pattern, argv)
                        for pattern in FP_EXCLUDES)
            if not argv or is_fp:
                continue
            users[argv][0].add(pid)
            users[argv][1].update(deletedlibs)

    if read_failure:
        sys.stderr.write(PERMWARNING)

    if restart:
        restart_services(users)
    elif len(users) > 0:
        print(fmt_machine(users))


def usage():
    """Output usage info"""
    print("Lib_users version %s" % (__version__))
    print("")
    print("Usage: %s -[hm] --[help|machine]" % (sys.argv[0]))
    print("   -h, --help    - This text")
    print("   -r, --restart - Restart services automatically")


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] in ["-h", "--help"]:
        usage()
        sys.exit(0)
    elif len(sys.argv) > 1 and sys.argv[1] in ["-r", "--restart"]:
        main(True)
    else:
        main()
