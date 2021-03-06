/*
   Programacao Logica - Prof. Alexandre G. Silva - 30set2015
     Versao inicial     : 30set2015
     Ultima atualizacao : 12set2017

   RECOMENDACOES:

   - O nome deste arquivo deve ser 'programa.pl'

   - O nome do banco de dados deve ser 'desenhos.pl'

   - Dicas de uso podem ser obtidas na execucação:
     ?- menu.

   - Exemplo de uso:
     ?- load.
     ?- searchAll(id1).

   - Colocar o nome e matricula de cada integrante do grupo
     nestes comentarios iniciais do programa
*/

:- initialization(load).

% Exibe menu principal
menu :-
    write('load.         -> Carrega todos os desenhos do banco de dados para a memoria'), nl,
    write('commit.       -> Grava alteracoes de todos os desenhos no banco de dados'), nl,
    write('new(Id,X,Y).  -> Insere ponto/deslocamento no desenho com identificador <Id>'), nl,
    write('search.       -> Consulta pontos/deslocamentos dos desenhos'), nl,
    write('remove.       -> Remove pontos/deslocamentos dos desenhos'), nl,
    write('svg.          -> Cria um arquivo de imagem vetorial SVG (aplica "commit." antes'), nl.

% Apaga os predicados 'xy' da memoria e carrega os desenhos a partir de um arquivo de banco de dados
load :-
    retractall(xy(_,_,_)),
    open('desenhos.pl', read, Stream),
    repeat,
        read(Stream, Data),
        (Data == end_of_file -> true ; assert(Data), fail),
        !,
        close(Stream).

% Grava os desenhos da memoria em arquivo
commit :-
    open('desenhos.pl', write, Stream),
    telling(Screen),
    tell(Stream),
    listing(xy),  %listagem dos predicados 'xy'
    tell(Screen),
    close(Stream).

% Ponto de deslocamento, se <Id> existente
new(Id,X,Y) :-
    xy(Id,_,_),
    assertz(xy(Id,X,Y)),
    !.

% Ponto inicial, caso contrario
new(Id,X,Y) :-
    asserta(xy(Id,X,Y)),
    !.

% Exibe opcoes de busca
search :-
    write('searchId(Id,L).  -> Monta lista <L> com ponto inicial e todos os deslocamentos de <Id>'), nl,
    write('searchFirst(L).  -> Monta lista <L> com pontos iniciais de cada <Id>'), nl,
    write('searchLast(L).   -> Monta lista <L> com pontos/deslocamentos finais de cada <Id>'), nl.

% Exibe opcoes de remocao
remove :-
    write('removeLast.      -> Remove todos os pontos/deslocamentos de <Id>'), nl,
    write('removeLast(Id).  -> Remove o ultimo ponto de <Id>'), nl.

% Grava os desenhos em SVG
svg :-
    commit,
    open('desenhos.svg', write, Stream),
    telling(Screen),
    tell(Stream),
    consult('db2svg.pl'),  %programa para conversao
    tell(Screen),
    close(Stream).

%------------------------------------
% t2A
% -----------------------------------

% Questao 1 (resolvida)
% Monta lista <L> com ponto inicial e todos os deslocamentos de <Id>
searchId(Id,L) :-
    bagof([X,Y], xy(Id,X,Y), L).


% Questao 2
% Monta lista <L> com pontos iniciais de cada <Id>

getFirsts(A, [H|T], L) :-
        searchId(H, List), nth0(0, List, Aux), append(A, [Aux], PI), getFirsts(PI, T, L), !.
getFirsts(A, [H|T], L) :- 
        last([H|T], H), searchId(H, List), nth0(0, List, Aux), append(A, [Aux], PI), append([L], PI), !.

searchFirst(L) :- setof(Id, X^Y^xy(Id,X,Y), List), getFirsts([], List, L).
    
% Questao 3
% Monta lista <L> com pontos ou deslocamentos finais de cada <Id>


getLasts(A, [H|T], L) :-
    searchId(H, List), length(List, N), nth1(N, List, Aux), append(A, [Aux], PF), getLasts(PF, T, L), !.

getLasts(A, [H|T], L):-
    last([H|T], H), searchId(H, List), length(List, N), nth1(N, List, Aux), append(A, [Aux], PF), append([L], PF), !.

searchLast(L) :- 
    setof(Id, X^Y^xy(Id, X, Y), List), getLasts([], List, L).


% Questao 4
% Remove todos os pontos ou deslocamentos do ultimo <Id>

lastId(List, Lid) :- length(List, A), nth1(A, List, Lid).
removeLast :-
    setof(Id, X^Y^xy(Id, X, Y), List), lastId(List, Lid), retractall(xy(Lid, _, _)).

% Questao 5
% Remove o ultimo ponto ou deslocamento de <Id>


getLastP(List, Pontos) :- length(List, A), nth1(A, List, Pontos), !.
splitP(Lista, X, Y) :- nth0(0, Lista, X), nth0(1, Lista, Y).
removeLast(Id) :- bagof([X,Y], xy(Id, X, Y), List),
            getLastP(List, Pontos), splitP(Pontos, X, Y), retract(xy(Id,X,Y)).

% Questao 6
% Determina um novo <Id> na sequencia numerica existente

incId(Id, Lista) :- length(Lista, A), nth1(A, Lista, Aux), Id is Aux + 1.
newId(Id) :- setof(Id, X^Y^xy(Id, X, Y), Lista), incId(Id, Lista).

% Questao 7
% Duplica a figura com <Id> a partir de um nova posicao (X,Y)
% Deve ser criado um <Id_novo> conforme a sequencia (questao 6)
cloneId(Id,X,Y) :- true.

