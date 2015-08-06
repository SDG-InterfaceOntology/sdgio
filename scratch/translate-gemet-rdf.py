#!/usr/bin/env python3

__author__ = 'cjm'


import rdflib

g = rdflib.Graph()
result = g.parse("gemet-all.rdf")

# prints graph has 79 statements.

termdict = dict()
groupdict = dict()

def write_stanza(obj):
    if obj['id'] in groupdict:
        return
    print("[Term]")
    print("id: "+obj['id'])
    if ('label' in obj):
        print("name: "+obj['label'])
    if ('is_a' in obj):
        print("is_a: "+obj['is_a'])
    if ('group' in obj):
        print("subset: "+get_subset(obj['group']))
    print("")

def get_term(id):
    if id in termdict:
        return termdict[id]
    else:
        termdict[id] = dict()
        termdict[id]['id'] = id
        return termdict[id]

def get_subset(id):
    n = get_term(id)['label']
    return n.replace(" ","_").replace(",","").replace("(","").replace(")","")

for subj1, pred1, obj1 in g:
    subj = str(subj1)
    obj = str(obj1)
    pred = str(pred1)
    if pred == 'http://www.w3.org/2004/02/skos/core#prefLabel':
        get_term(subj)['label'] = obj
    if pred == 'http://www.w3.org/2000/01/rdf-schema#label':
        get_term(subj)['label'] = obj
    elif pred == 'http://www.w3.org/2004/02/skos/core#broader':
        get_term(subj)['is_a'] = obj
    elif pred == 'http://www.eionet.europa.eu/gemet/2004/06/gemet-schema.rdf#group':
        get_term(subj)['group'] = obj
        groupdict[obj] = 1

print("ontology: gemet")
for k in groupdict:
    n = get_subset(k)
    print('subsetdef: '+n+' "' + n + '"')

print("")

for k in termdict:
    write_stanza(termdict[k])



