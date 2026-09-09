import sys
import site
# Interpret the .pth files in the isolated Python site, but make sure they are
# prepended to the sys.path so that they take precedence.
original_paths = [x for x in sys.path]  # Done this way to clone the list.
site.addsitedir('@@PREFIX@@/libexec/eso/lib/python2.7/site-packages')
new_paths = [x for x in sys.path if x not in original_paths]
sys.path = new_paths + original_paths
