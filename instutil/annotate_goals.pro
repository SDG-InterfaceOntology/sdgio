:- use_module(bio(annotator)).

ok('ENVO').
ok('SDGIO').
ok('PCO').
ok('NCBITaxon').
ok('GEMET').
not_obo('SDGIO').
%not_obo('GEMET').


ix :-
        format('@base <http://purl.unep.org/sdg/> .~n'),
        %format('@prefix ENVO: <http://purl.obolibrary.org/obo/ENVO_> .~n'),
        format('@prefix SDGIO: <http://purl.unep.org/sdg/SDGIO_> .~n'),
        format('@prefix has-participant: <http://purl.obolibrary.org/obo/RO_0000057> .~n'),
        format('@prefix has-part: <http://purl.obolibrary.org/obo/BFO_0000051> .~n'),
        format('@prefix mentions: <http://purl.unep.org/sdg/MENTIONS> .~n'),
        forall((ok(S),\+not_obo(S)),
               format('@prefix ~w: <http://purl.obolibrary.org/obo/~w_> .~n',[S,S])),
        format('## AUTO:~n'),
        nl,
        initialize_annotator.

exclude_list([
              all,
              sound
             ]).

              
annotate_label(C,MC) :-
        rdfs_label(C,L),
        exclude_list(XL),
        sentence_annotate(L,Matches,[excludes([L|XL])]),
        member(m([MC|_],_,_),Matches),
        class(MC,MCN),
        debug(ann,'Annotating: ~w ==> ~w "~w"',[L,MC,MCN]),
        is_ok(MC),
        format('<~w> mentions: ~w .~n',[C,MC]),
        fail.

is_ok(C) :-
        id_idspace(C,S),
        ok(S),
        !.
is_ok(C) :-
        debug(ann,'BAD: ~w',[C]),
        fail.



cls_rel(C,'has-participant:') :-
        subclassT(C,'BFO:0000040'),
        !.
cls_rel(C,'has-part:') :-
        subclassT(C,'BFO:0000015'),
        !.
cls_rel(_,'mentions:') :- !.





/*

blip-findall -goal ix -i z.ttl -consult annotate_goals.pro annotate_label/3
*/

        

