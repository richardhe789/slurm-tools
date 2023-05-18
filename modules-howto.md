```
$ rpm -qa | grep modules
environment-modules-3.2

$ rpm -ql environment-modules-3.2
/etc/modulefiles
/etc/profile.d/modules.csh
/etc/profile.d/modules.sh
/usr/share/Modules/init/.modulepath

$ type -a module
module is a function
module ()
{
	eval `/usr/bin/modulecmd bash $*`
}

$ module av

$ cat /usr/share/Modules/init/.modulepath
/etc/modulefiles
/usr/share/Modules/modulefiles
# customized module files
/usr/local/Modules/modulefiles

$ echo $MODULEHOME
/usr/share/Modules

$ set | grep MODULEPATH
MODULEPATH=/usr/local/Modules/modulefiles:/usr/local/Modules/modulefiles

$ cat /usr/local/Modules/modulefiles/R/4.2.3
#%Module

proc ModulesHelp{}{
	puts stderr "This module adds R 4.2.3 to your path"
}

module-whatis 	"This module adds R 4.2.3 to your path"
set basedir "/usr/local/R/4.2.3"
prepend-path PATH "${basedir}/bin"
prepend-path LD_LIBRARY_PATH "${basedir}/lib64"
prepend-path MANPATH "${basedir}/share/man"
```

Module commands
```
module av
module list
module show R/4.2.3
module purge
```

Create your own modulefiles
```
mkdir ~/.personalModulefiles
module use /home/myusername/.personalModulefiles
```

Use more modules
```
module use --append /some/where/modulefiles
```
