--Função para calcula a quantidade de horas úteis, considerando jornada de 8 as 17h e excluindo sábados, domingos e feriados

CREATE OR REPLACE Function HORAS_UTEIS(stime IN DATE,
                                       etime IN DATE) RETURN NUMBER IS
  NHORAS NUMBER;
  NFERIADOS NUMBER;

BEGIN
  --calcula o numero de horas úteis considerando jornada de 8 as 17h de segunda a sexta-feira
 SELECT sum(elap)elap
  INTO NHORAS
    FROM (select r,
                 greatest(stime, trunc(stime) + 8/ 24 + r),
                 least(trunc(stime) + r + 17 / 24, etime),
                 (least(trunc(stime) + r + 17 / 24, etime) -
                 greatest(stime, trunc(stime) + 8 / 24 + r)) * 24 elap
            from dual,
                 (select rownum - 1 r
                    from all_objects
                   where rownum <=
                         (select trunc(etime) - trunc(stime) + 1 from dual))
           where to_char(stime + r, 'D') not in (1,7));
           
--calcula o número de horas de feriados
SELECT CASE
         WHEN QTD = 1 THEN
          9
         WHEN QTD = 2 THEN
          18
         WHEN QTD = 3 THEN
          27
         WHEN QTD = 4 THEN
          36
         ELSE
          0
       END QTD INTO NFERIADOS
  FROM (
SELECT COUNT(PERIODO) QTD
  FROM FERIADOS F
 WHERE 
 TO_NUMBER(TO_CHAR(F.PERIODO, 'DD')) BETWEEN TO_NUMBER(TO_CHAR(STIME, 'DD')) AND  
       (TO_CHAR(SYSDATE, 'DD'))
 AND TO_NUMBER(TO_CHAR(F.PERIODO, 'MM')) BETWEEN TO_NUMBER(TO_CHAR(STIME, 'MM')) AND 
       (TO_CHAR(SYSDATE, 'MM'))
   AND TO_NUMBER(TO_CHAR(F.PERIODO, 'YYYY')) BETWEEN TO_NUMBER(TO_CHAR(STIME, 'YYYY')) AND 
       TO_NUMBER(TO_CHAR(SYSDATE, 'YYYY'))
   AND F.DIA NOT IN (1, 7));      
   

RETURN (NHORAS - NFERIADOS);
END;


/*Tabela FERIADOS
Periodo   Dia Descrição
27/02/2017	2	Carnaval
28/02/2017	3	Carnaval
19/03/2017	1	São José
25/03/2017	7	Data Magna do Estado
14/04/2017	6	Paixão de Cristo
21/04/2017	6	Tiradentes
01/05/2017	2	Dia do Trabalho
15/06/2017	5	Corpus Christi
15/08/2017	3	N. Sra. da  Assunção
07/09/2017	5	Independência
12/10/2017	5	N. Sra. Aparecida 
02/11/2017	5	Finados
15/11/2017	4	Proclamação da República
25/12/2017	2	Natal*/


--chamada das funções para calculo do número de horas úteis
U063.HORAS_UTEIS(J.CREATED,SYSDATE)
