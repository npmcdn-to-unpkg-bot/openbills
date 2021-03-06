/*consultas

POLITICOS COM MUITOS BENS:
ALUÍZIO BEZERRA DE OLIVEIRA  00340243104
			2006        | 10329                |      0
 			2008        | 560                  | 382900


exibir os candidatos cujo valor de bem vem aumentando a cada ano que passa

*/


#BENS X TEMPO

#consulta para listar valor de bem em relação ao ano COM DETALHE DO BEM:
;select distinct b.ANO_ELEICAO, c.NOME_CANDIDATO, c.SEQUENCIAL_CANDIDATO, b.VALOR_BEM, b.DETALHE_BEM from BEM_CANDIDATO b, CONSULTA_CAND c WHERE c.CPF_CANDIDATO = '13814443268' AND c.SEQUENCIAL_CANDIDATO = b.SQ_CANDIDATO order by b.ANO_ELEICAO asc ;

#consulta para listar valor de bem em relação ao ano SOMANDO BENS:
;select distinct b.ANO_ELEICAO,  sum (b.VALOR_BEM) from BEM_CANDIDATO b, CONSULTA_CAND c WHERE c.CPF_CANDIDATO = '16986644272' AND c.SEQUENCIAL_CANDIDATO = b.SQ_CANDIDATO group by b.ANO_ELEICAO order by b.ANO_ELEICAO asc ;



#CANDIDATOS ELEITOS - RETORNAR TODOS OS CANDIDATOS ELEITOS N VEZES

#exibir quantas as vezes em q um candidato foi eleito
;select c.DATA_GERACAO, c.SEQUENCIAL_CANDIDATO, c.ANO_ELEICAO, c.NOME_CANDIDATO, c.CPF_CANDIDATO from CONSULTA_CAND c where c.DESC_SIT_TOT_TURNO = 'ELEITO'  and c.CPF_CANDIDATO = '16986644272';

#exibir pessoas eleitas N vezes
;select c.NOME_CANDIDATO, c.CPF_CANDIDATO, count(*)  from CONSULTA_CAND c where c.DESC_SIT_TOT_TURNO = 'ELEITO' group by c.NOME_CANDIDATO, c.CPF_CANDIDATO having count(*) >= 2;


#procurar todos doadores q nao sejam doadores de si mesmos
;SELECT t.CD_CPF_CNPJ_FORNECEDOR cpf, t.NM_FORNECEDOR nome FROM DESPESA_CAND_2010 t WHERE t.CD_CPF_CNPJ_FORNECEDOR != t.CPF;

		  
;SELECT t.CD_CPF_CNPJ_DOADOR cpf, t.NM_DOADOR nome FROM RECEITA_CAND_2010 t WHERE t.CD_CPF_CNPJ_DOADOR != t.CD_NUM_CPF;

#uniao entre tabelas receita e despesas
;SELECT cpf, nome FROM ( (SELECT t.CD_CPF_CNPJ_FORNECEDOR cpf, t.NM_FORNECEDOR nome FROM DESPESA_CAND_2010 t WHERE t.CD_CPF_CNPJ_FORNECEDOR != t.CPF) UNION (SELECT t.CD_CPF_CNPJ_DOADOR cpf, t.NM_DOADOR nome FROM RECEITA_CAND_2010 t WHERE t.CD_CPF_CNPJ_DOADOR != t.CD_NUM_CPF) ) as doadores;


#get financiados de um doador
;SELECT cc.CPF_CANDIDATO cpf, cc.NOME_CANDIDATO nome FROM CONSULTA_CAND cc, ( (SELECT t.CPF candCPF, t.CD_CPF_CNPJ_FORNECEDOR cpf, t.NM_FORNECEDOR nome FROM DESPESA_CAND_2010 t WHERE t.CD_CPF_CNPJ_FORNECEDOR != t.CPF) UNION (SELECT t.CD_NUM_CPF candCPF, t.CD_CPF_CNPJ_DOADOR cpf, t.NM_DOADOR nome FROM RECEITA_CAND_2010 t WHERE t.CD_CPF_CNPJ_DOADOR != t.CD_NUM_CPF) ) un WHERE un.cpf = '00302347000199' AND  un.candCPF = CC.CPF_CANDIDATO;

#get financiados de um doador com detalhe do doador
;SELECT un.cpf, un.nome, un.candCPF FROM ( (SELECT t.CPF candCPF, t.CD_CPF_CNPJ_FORNECEDOR cpf, t.NM_FORNECEDOR nome FROM DESPESA_CAND_2010 t WHERE t.CD_CPF_CNPJ_FORNECEDOR != t.CPF) UNION (SELECT t.CD_NUM_CPF candCPF, t.CD_CPF_CNPJ_DOADOR cpf, t.NM_DOADOR nome FROM RECEITA_CAND_2010 t WHERE t.CD_CPF_CNPJ_DOADOR != t.CD_NUM_CPF) ) un WHERE un.cpf = '02122405000128';

#encontrar quem financiou mais de x politicos
;SELECT t.CD_CPF_CNPJ_FORNECEDOR cpf, t.NM_FORNECEDOR nome, count(*) FROM DESPESA_CAND_2010 t WHERE t.CD_CPF_CNPJ_FORNECEDOR != t.CPF GROUP BY t.CD_CPF_CNPJ_FORNECEDOR, t.NM_FORNECEDOR HAVING count(*) > 2;



#agg = (select json_agg(fn) from (SELECT cc.CPF_CANDIDATO cpf, cc.NOME_CANDIDATO nome FROM CONSULTA_CAND cc WHERE un.candCPF = cc.CPF_CANDIDATO ) fn)

#DISTINCT CONSULTA_CAND AGG
#agg = (select json_agg(fn) from (SELECT cc.CPF_CANDIDATO cpf, cc.NOME_CANDIDATO nome FROM CONSULTA_CAND cc WHERE un.candCPF = cc.CPF_CANDIDATO ) fn)


#TEMPLATE PARA CONSULTA RETORNANDO JSON COM AGREGADOS
;select row_to_json(dd) as doadores from(select undis.cpf, un.nome, (agg) as financiados from GETDis as undis, GETDn un where undis.cpf = un.cpf ) dd;

#PEGAR DOADORES JUNTO COM SEUS FINANCIADOS: JSON
;select row_to_json(dd) as doadores from(select un.cpf, un.nome, ((select json_agg(fn) from (SELECT cc.CPF_CANDIDATO cpf, cc.NOME_CANDIDATO nome FROM CONSULTA_CAND cc WHERE un.candCPF = cc.CPF_CANDIDATO ) fn)) as financiados from ( (SELECT t.CPF candCPF, t.CD_CPF_CNPJ_FORNECEDOR cpf, t.NM_FORNECEDOR nome FROM DESPESA_CAND_2010 t WHERE t.CD_CPF_CNPJ_FORNECEDOR != t.CPF) UNION (SELECT t.CD_NUM_CPF candCPF, t.CD_CPF_CNPJ_DOADOR cpf, t.NM_DOADOR nome FROM RECEITA_CAND_2010 t WHERE t.CD_CPF_CNPJ_DOADOR != t.CD_NUM_CPF) ) as un ) dd;



#get doadores distintos com agregados template (n funcionando)
;select row_to_json(dd) as doadores from(select undis.cpf, un.nome, (agg) as financiados from GETDis as undis, GETDn un where undis.cpf = un.cpf ) dd;




#PEGAR POLITICOS SEM REPETIÇÕES
;select cpf_candidato, nome_candidato from ( select *, row_number() over (partition by cpf_candidato order by nome_candidato) as row_number from CONSULTA_CAND ) as rows where row_number = 1;



#TEMPLATE

select row_to_json(dd) as doadores
from(
  select doador.id, doador.name, 
  (select json_agg(fn)
  from (
    select SELECAO from distinctPolitics, (UNIAO DOADORES) und2  dps where artist_id = doador.id
  ) fn
) as dps
from UNIAO_DOADORES as doador) dd;





;select row_to_json(dd) as doadores from( select doador.cpf, doador.nome, (select json_agg(fn) from ( select cpf_candidato, nome_candidato from (select cpf_candidato, nome_candidato from ( select *, row_number() over (partition by cpf_candidato order by nome_candidato) as row_number from CONSULTA_CAND ) as rows where row_number = 1) dps,  ( (SELECT t.CPF candCPF, t.CD_CPF_CNPJ_FORNECEDOR cpf, t.NM_FORNECEDOR nome FROM DESPESA_CAND_2010 t WHERE t.CD_CPF_CNPJ_FORNECEDOR != t.CPF) UNION (SELECT t.CD_NUM_CPF candCPF, t.CD_CPF_CNPJ_DOADOR cpf, t.NM_DOADOR nome FROM RECEITA_CAND_2010 t WHERE t.CD_CPF_CNPJ_DOADOR != t.CD_NUM_CPF) ) und2 where cpf_candidato = doador.candCPF and und2.cpf = doador.candCPF ) fn ) as dps from ( (SELECT t.CPF candCPF, t.CD_CPF_CNPJ_FORNECEDOR cpf, t.NM_FORNECEDOR nome FROM DESPESA_CAND_2010 t WHERE t.CD_CPF_CNPJ_FORNECEDOR != t.CPF) UNION (SELECT t.CD_NUM_CPF candCPF, t.CD_CPF_CNPJ_DOADOR cpf, t.NM_DOADOR nome FROM RECEITA_CAND_2010 t WHERE t.CD_CPF_CNPJ_DOADOR != t.CD_NUM_CPF) ) as doador) dd;




#UNIAO ENTRE 2 TABELAS
( (SELECT t.CPF candCPF, t.CD_CPF_CNPJ_FORNECEDOR cpf, t.NM_FORNECEDOR nome FROM DESPESA_CAND_2010 t WHERE t.CD_CPF_CNPJ_FORNECEDOR != t.CPF) UNION (SELECT t.CD_NUM_CPF candCPF, t.CD_CPF_CNPJ_DOADOR cpf, t.NM_DOADOR nome FROM RECEITA_CAND_2010 t WHERE t.CD_CPF_CNPJ_DOADOR != t.CD_NUM_CPF) )


#window function 
(select cpf_candidato, nome_candidato from ( select *, row_number() over (partition by cpf_candidato order by nome_candidato) as row_number from CONSULTA_CAND ) as rows where row_number = 1)



#VIEW UNIAO DOADORES
;CREATE VIEW uniaoDoadores AS SELECT * FROM ( (SELECT t.CPF candCPF, t.CD_CPF_CNPJ_FORNECEDOR cpf, t.NM_FORNECEDOR nome FROM DESPESA_CAND_2010 t WHERE t.CD_CPF_CNPJ_FORNECEDOR != t.CPF) UNION (SELECT t.CD_NUM_CPF candCPF, t.CD_CPF_CNPJ_DOADOR cpf, t.NM_DOADOR nome FROM RECEITA_CAND_2010 t WHERE t.CD_CPF_CNPJ_DOADOR != t.CD_NUM_CPF) ) d;

#VIEW PARA DOADORES DISTINTOS
;CREATE VIEW distinctDoadores AS SELECT * FROM (select * from ( select *, row_number() over (partition by cpf order by nome) as row_number from uniaoDoadores ) as rows where row_number = 1) dd;

#VIEW PARA POLITICOS DISTINTOS
;CREATE VIEW distinctPoliticos AS SELECT * FROM (select cpf_candidato, nome_candidato from ( select *, row_number() over (partition by cpf_candidato order by nome_candidato) as row_number from CONSULTA_CAND ) as rows where row_number = 1) dp;




;select row_to_json(dd) as doadores from( select doador.cpf, doador.nome,  (select json_agg(fn) from ( select j.candCPF, j.nome_candidato from (select * from uniaoDoadores dsd, distinctPoliticos c where dsd.cpf = doador.cpf and dsd.candCPF = c.cpf_candidato ) j   ) fn ) as dps from distinctDoadores as doador) dd;