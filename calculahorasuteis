--Função para calcula a quantidade de horas úteis, considerando jornada de 8 as 17 e excluindo sábados e domingos

CREATE OR REPLACE Function HORAS_UTEIS(stime IN DATE,
                                       etime    IN DATE) RETURN number IS
  HORAS number;

BEGIN

  SELECT sum(elap)
    INTO HORAS
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
           where to_char(stime + r, 'Dy') not in ('Sáb', 'Dom'));
  RETURN HORAS;

END;

--Função para calcula o numero de horas de feriados

Tabela FERIADOS
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
25/12/2017	2	Natal

CREATE OR REPLACE Function CALCULA_FERIADOS
  RETURN number IS
  QTD_FERIADO number;

  BEGIN

SELECT CASE
         WHEN QTD = 1 THEN
          8
         WHEN QTD = 2 THEN
          16
         WHEN QTD = 3 THEN
          24
         WHEN QTD = 4 THEN
          32
         ELSE
          0
       END QTD INTO QTD_FERIADO
  FROM (
        --RETORNA QUANTIDADE DE FERIADOS DO MES/ANO ATÉ O DIA ATUAL
        SELECT COUNT(PERIODO) QTD
          FROM FERIADOS F
         WHERE to_number(TO_CHAR(F.PERIODO, 'MM')) =
               to_number(TO_CHAR(sysdate, 'mm'))
           and to_number(TO_CHAR(f.PERIODO, 'yyyy')) =
               to_number(TO_CHAR(sysdate, 'yyyy'))
           and TO_NUMBER(TO_CHAR(F.PERIODO, 'DD')) <=
               (SELECT MAX(to_number(to_char(DATAS_MES + LEVEL - 1, 'dd'))) DATA_
                  FROM (SELECT TRUNC(to_date('01/' ||
                                             to_char(sysdate, 'MM/YYYY'),
                                             'DD/MM/YYYY')) DATAS_MES
                          FROM DUAL)
                CONNECT BY DATAS_MES + LEVEL - 1 <= sysdate)
           and f.dia NOT IN (1, 7));
RETURN QTD_FERIADO;
END;

--chamada das funções para calculo do número de horas úteis
(U063.HORAS_UTEIS(J.CREATED,SYSDATE)) - (u063.calcula_feriados)
