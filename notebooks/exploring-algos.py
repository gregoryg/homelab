import pandas as pd
# Set up pyTigerGraph access
import pyTigerGraph as tg

# Prepare to pull our GSQL algorithms from GitHub
import requests


host       = "http://protomolecule.magichome" # must include the protocol http or https
username   = "tigergraph"
password   = "Tigergraph"
restppPort = 9000       # default 9000
gsPort     = 14240       # default 14240

# graphName  = "Northwind" # leave blank to use Global
# mysecret   = "7vcupj59t7p4ji9t0k3s72nm4bheilig"
# token="4vsf41mpl57e6m19pf0c5q1eah6h6jm5"

graphName = "Patents"
mysecret = "iksujn9605n4ltklm012a6uiann87rrn"
token = "15bg00akkb2ume2of295ld38h6ge9270"

graphName = "social"
mysecret = "ifn4pc4jnkktim9u80ahhvebkj38g71n"
token = "9icvamj2undegsfc72e5uph8udj2f3nf"

# First establish a basic connection using a secret.  Do *not* do this if you already have a token
# conn = tg.TigerGraphConnection(host=host, restppPort=restppPort, gsPort=gsPort, graphname=graphName, password=password)
# token = conn.getToken(mysecret, setToken=True, lifetime=None)[0]

# Next use the new token to establish a full access connection for use with GSQL

# Check PageRank for Reps - rep_order
max_change    = 0.001     # default 0.001
max_iter      = 25        # default 25
damping       = 0.85      # default 0.85
top_k         = 100       # default 100
print_accum   = True      # default TRUE
result_attr   = ""        # default ""
file_path     = ""        # default ""
display_edges = False     # default FALSE
vtype = 'Reps'
etype = 'rep_order'

vtype = 'Application'
etype = 'has_parent'

vtype = "Person"
etype = "Friend"
pagerankj = conn.runInstalledQuery('tg_pagerank',
                                   params={'v_type': vtype,
                                           'max_iter': 25,
                                           'e_type': etype,
                                           'damping': damping,
                                           'top_k': top_k,
                                           'print_accum': print_accum,
                                           'result_attr': result_attr,
                                           'file_path': file_path,
                                           'display_edges': display_edges
                                          })
pd.DataFrame(pagerankj[0]['@@top_scores_heap'])
conn.getVertexTypes()
# Check PageRank for Reps - rep_order
max_change    = 0.001     # default 0.001
max_iter      = 25        # default 25
damping       = 0.85      # default 0.85
top_k         = 100       # default 100
print_accum   = True      # default TRUE
result_attr   = ""        # default ""
file_path     = ""        # default ""
display_edges = False     # default FALSE
vtype = 'Reps'
etype = 'rep_order'

vtype = 'Application'
etype = 'has_parent'

vtype = "Person"
etype = "Friend"
pagerankj = conn.runInstalledQuery('tg_pagerank',
                                   params={'v_type': vtype,
                                           'max_iter': 50,
                                           'e_type': etype,
                                           'damping': damping,
                                           'top_k': top_k,
                                           'print_accum': print_accum,
                                           'result_attr': result_attr,
                                           'file_path': file_path,
                                           'display_edges': display_edges
                                          })
pd.DataFrame(pagerankj[0]['@@top_scores_heap'])

conn.getVertexDataframe('Person')

conn.getEdgesDataframe('Person', 'Fiona')

# Use Customer360
graphName = "Customer360"
mysecret = "q6g6qa738ufhnm4fqmu7pl60ik6jcrld"
token = "7vib70gv06eaesnocp5u3tvgmgmg8e1a"
# token = "9icvamj2undegsfc72e5uph8udj2f3nf"

# First establish a basic connection using a secret.  Do *not* do this if you already have a token
# conn = tg.TigerGraphConnection(host=host, restppPort=restppPort, gsPort=gsPort, graphname=graphName, password=password)
# token = conn.getToken(mysecret, setToken=True, lifetime=None)[0]

# Next use the new token to establish a full access connection for use with GSQL

conn = tg.TigerGraphConnection(host=host, restppPort=restppPort, gsPort=gsPort, graphname=graphName, password=password, apiToken=token)
# token
# Check PageRank for Reps - rep_order
max_change    = 0.001     # default 0.001
max_iter      = 25        # default 25
damping       = 0.85      # default 0.85
top_k         = 100       # default 100
print_accum   = True      # default TRUE
result_attr   = ""        # default ""
file_path     = ""        # default ""
display_edges = False     # default FALSE

vtype = "Profile"
etype = "profile_friends"
pagerankj = conn.runInstalledQuery('tg_pagerank',
                                   params={'v_type': vtype,
                                           'max_iter': 50,
                                           'e_type': etype,
                                           'damping': damping,
                                           'top_k': top_k,
                                           'print_accum': print_accum,
                                           'result_attr': result_attr,
                                           'file_path': file_path,
                                           'display_edges': display_edges
                                          })
pd.DataFrame(pagerankj[0]['@@top_scores_heap'])

# Check PageRank for Reps - rep_order
max_change    = 0.001     # default 0.001
max_iter      = 25        # default 25
damping       = 0.85      # default 0.85
top_k         = 100       # default 100
print_accum   = True      # default TRUE
result_attr   = ""        # default ""
file_path     = ""        # default ""
display_edges = False     # default FALSE

vtype = "Profile"
etype = "profile_friends"
pagerankj = conn.runInstalledQuery('tg_pagerank',
                                   params={'v_type': vtype,
                                           'max_iter': 50,
                                           'e_type': etype,
                                           'damping': damping,
                                           'top_k': top_k,
                                           'print_accum': print_accum,
                                           'result_attr': result_attr,
                                           'file_path': file_path,
                                           'display_edges': display_edges
                                          })
pd.DataFrame(pagerankj[0]['@@top_scores_heap'])

conn.getVertexDataframeById('Profile', vertexIds=[8157, 4139, 3090])
