;; Python and Jupyter goodies
(specifications->manifest
 '(
   "python"
   "python-pip"
   "python-ipython"
   "python-pandas"
   ;; "python-google-api-client"
   "python-jupyter-server"
   ;; "python-google"
   "python-jupyterlab-widgets"
   "openssl"
   "r-openssl"
   "r"
   "gcc-toolchain"
   "gfortran-toolchain"
   "r-devtools" ; required for R kernel install in Jupyter
   "r-irkernel" ; required for R kernel install in Jupyter
   ))
